package dev.angelflower.caralign;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioPlaybackCaptureConfiguration;
import android.media.AudioRecord;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.media.AudioTrack;
import android.os.IBinder;
import android.os.Process;
import android.util.Log;

import java.io.File;

public class CaptureService extends Service {
    private static final String TAG = "CarAlign";
    /** Read by the UI to know whether a capture is running. */
    static volatile boolean active;
    /** Notice code for the UI (e.g. "captureBlocked"); the UI reads and clears it. */
    static volatile String notice = "";

    private volatile boolean running;
    private volatile DelayLine delayLine;

    /** Tuning for latency experiments: files/tuning.txt with key=value lines (block, track_frames, rec_frames, ll). */
    private int tun(String key, int def) {
        try {
            File d = getExternalFilesDir(null);
            File f = d == null ? null : new File(d, "tuning.txt");
            if (f == null || !f.exists()) return def;
            for (String line : java.nio.file.Files.readAllLines(f.toPath())) {
                String[] kv = line.trim().split("=");
                if (kv.length == 2 && kv[0].trim().equals(key)) return Integer.parseInt(kv[1].trim());
            }
        } catch (Exception ignored) { }
        return def;
    }

    /** getParcelableExtra(String, Class) is Android 13+; Android 10-12 need the old overload. */
    @SuppressWarnings("deprecation")
    private static Intent projectionData(Intent i) {
        return android.os.Build.VERSION.SDK_INT >= 33 ? i.getParcelableExtra("data", Intent.class)
                : (Intent) i.getParcelableExtra("data");
    }

    private void touchMarker() {
        SharedDirs.touch(this, "active");
    }

    /** The "active" marker exists only while capturing; the shell guard reads it. */
    private void setActive(boolean on) {
        if (on) SharedDirs.touch(this, "active");
        else SharedDirs.delete(this, "active");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (running) {
            // already capturing: an intent without a projection only adjusts the delay; one with it is ignored
            if (!intent.hasExtra("data") && delayLine != null) {
                int samples = Math.round(intent.getFloatExtra("delay_ms", 0f) * 48f);
                boolean left = intent.getBooleanExtra("left", true);
                float rampS = intent.getFloatExtra("ramp_s", 0f);
                Log.i(TAG, "delay -> " + samples + " samples (" + (left ? "left" : "right") + ")"
                        + (rampS > 0 ? " over " + rampS + " s" : ""));
                if (rampS > 0) delayLine.ramp(left, samples, rampS);
                else delayLine.set(left, samples);
            }
            return START_NOT_STICKY;
        }
        NotificationChannel ch = new NotificationChannel("c", "capture", NotificationManager.IMPORTANCE_LOW);
        getSystemService(NotificationManager.class).createNotificationChannel(ch);
        Notification n = new Notification.Builder(this, "c").setContentTitle("CarAlign capture")
                .setSmallIcon(android.R.drawable.ic_media_play).build();
        startForeground(1, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION);

        int code = intent.getIntExtra("code", 0);
        Intent data = projectionData(intent);
        MediaProjection mp = getSystemService(MediaProjectionManager.class).getMediaProjection(code, data);
        mp.registerCallback(new MediaProjection.Callback() {
            @Override public void onStop() { Log.i(TAG, "projection stopped"); running = false; active = false; setActive(false); stopSelf(); }
        }, null);

        AudioPlaybackCaptureConfiguration cfg = new AudioPlaybackCaptureConfiguration.Builder(mp)
                .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                .addMatchingUsage(AudioAttributes.USAGE_GAME)
                .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
                .excludeUid(Process.myUid())
                .build();
        AudioFormat fmt = new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setSampleRate(48000).setChannelMask(AudioFormat.CHANNEL_IN_STEREO).build();
        final int BLOCK = tun("block", 480);
        final int recFrames = tun("rec_frames", 48000), trackFrames = tun("track_frames", BLOCK * 3), ll = tun("ll", 1);
        Log.i(TAG, "tuning: block=" + BLOCK + " rec=" + recFrames + " track=" + trackFrames + " ll=" + ll);
        AudioRecord rec = new AudioRecord.Builder().setAudioPlaybackCaptureConfig(cfg)
                .setAudioFormat(fmt).setBufferSizeInBytes(recFrames * 4).build();
        AudioTrack track = new AudioTrack.Builder()
                .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setAudioFormat(new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(48000).setChannelMask(AudioFormat.CHANNEL_OUT_STEREO).build())
                .setPerformanceMode(ll == 1 ? AudioTrack.PERFORMANCE_MODE_LOW_LATENCY : AudioTrack.PERFORMANCE_MODE_NONE)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setBufferSizeInBytes(48000 * 4).build();
        final DelayLine dl = new DelayLine(Math.round(intent.getFloatExtra("delay_ms", 1f) * 48f),
                intent.getBooleanExtra("left", true));
        delayLine = dl;
        Log.i(TAG, "delay samples=" + Math.round(intent.getFloatExtra("delay_ms", 1f) * 48f));
        // Latency: 5 ms blocks and a bounded output queue (3 blocks = 15 ms); a 1 s buffer let ~80 ms pile up.
        track.setBufferSizeInFrames(trackFrames);
        running = true;
        rec.startRecording();
        track.play();
        active = true;
        setActive(true);
        new Thread(() -> {
            android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_URGENT_AUDIO);
            int silentWhileOthers = 0;
            boolean tripped = false; // safety breaker fired (own flag: the UI clears `notice` when it reads it)
            short[] buf = new short[BLOCK * 2];
            // drop whatever piled up before starting: otherwise that backlog stays as a constant delay
            while (rec.read(buf, 0, buf.length, AudioRecord.READ_NON_BLOCKING) > 0) { }
            int lastUnderruns = 0;
            long lastUnderrunDownMs = System.currentTimeMillis();
            long last = System.currentTimeMillis();
            int peak = 0;
            long framesRead = 0, framesWritten = 0, tRead = 0, tWrite = 0;
            android.media.AudioTimestamp tsIn = new android.media.AudioTimestamp(), tsOut = new android.media.AudioTimestamp();
            while (running) {
                int r = rec.read(buf, 0, buf.length);
                tRead = System.nanoTime();
                framesRead += r / 2;
                for (int i = 0; i < r; i++) peak = Math.max(peak, Math.abs(buf[i]));
                dl.process(buf, r);
                track.write(buf, 0, r);
                tWrite = System.nanoTime();
                framesWritten += r / 2;
                long now = System.currentTimeMillis();
                if (now - last >= 1000) {
                    String lat = "";
                    if (rec.getTimestamp(tsIn, android.media.AudioTimestamp.TIMEBASE_MONOTONIC) == AudioRecord.SUCCESS
                            && track.getTimestamp(tsOut)) {
                        double capMs = (tRead - (tsIn.nanoTime + (framesRead - 1 - tsIn.framePosition) * 1e9 / 48000)) / 1e6;
                        double outMs = (tsOut.nanoTime + (framesWritten - 1 - tsOut.framePosition) * 1e9 / 48000 - tWrite) / 1e6;
                        lat = String.format(java.util.Locale.US, " latency: capture %.0f ms + output %.0f ms = %.0f ms (block %d fr, track buf %d fr)",
                                capMs, outMs, capMs + outMs, r / 2, track.getBufferSizeInFrames());
                    }
                    int ur = track.getUnderrunCount();
                    if (ur > lastUnderruns) { // dropouts: grow the queue by one block (up to 100 ms) instead of letting them be heard
                        int bigger = Math.min(4800, track.getBufferSizeInFrames() + BLOCK);
                        track.setBufferSizeInFrames(bigger);
                        Log.i(TAG, "output underruns: queue grown to " + bigger + " fr");
                        lastUnderruns = ur;
                    }
                    if (ur == lastUnderruns && track.getBufferSizeInFrames() > trackFrames
                            && now - lastUnderrunDownMs > 30000) { // 30 s without dropouts: shrink the queue again
                        track.setBufferSizeInFrames(Math.max(trackFrames, track.getBufferSizeInFrames() - BLOCK));
                        lastUnderrunDownMs = now;
                    }
                    if (ur > lastUnderruns) lastUnderrunDownMs = now;
                    // Safety breaker: if another media app is playing but what we capture is silence, that app blocks
                    // capture (e.g. protected content). The guard has it muted, so nothing would be heard: stop
                    // capturing so the guard gives the original audio back.
                    // The public API only shows our own player; the shell guard sees them all and writes the count to "players"
                    int others = 0;
                    try {
                        String pf = SharedDirs.readFresh(CaptureService.this, "players", 5000);
                        if (pf != null) others = Integer.parseInt(pf);
                    } catch (Exception ignored) { }
                    silentWhileOthers = (peak == 0 && others >= 1) ? silentWhileOthers + 1 : 0;
                    if (silentWhileOthers >= 6) {
                        notice = "captureBlocked";
                        Log.w(TAG, "safety breaker: audio is playing but the capture is silent");
                        tripped = true;
                        running = false;
                    }
                    Log.i(TAG, "peak=" + peak + " underruns=" + ur + " others=" + others + " silent=" + silentWhileOthers + lat);
                    touchMarker(); // heartbeat: the guard only mutes while the marker keeps being renewed
                    peak = 0;
                    last = now;
                }
            }
            rec.stop();
            rec.release();
            track.stop();
            track.release();
            if (tripped) stopSelf(); // stopped by the breaker: release the service and the marker (onDestroy deletes it)
        }).start();
        return START_NOT_STICKY;
    }

    @Override public void onDestroy() { running = false; active = false; setActive(false); }

    @Override public IBinder onBind(Intent i) { return null; }
}
