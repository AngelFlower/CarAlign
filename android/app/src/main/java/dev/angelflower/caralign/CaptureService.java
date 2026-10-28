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
    /** Lo lee la interfaz para saber si se esta capturando. */
    static volatile boolean active;
    /** Aviso para la interfaz (p. ej. captura bloqueada por la app que suena); la interfaz lo lee y lo borra. */
    static volatile String notice = "";

    private volatile boolean running;
    private volatile DelayLine delayLine;

    /** Afinacion para experimentos de latencia: files/tuning.txt con lineas clave=valor (block, track_frames, rec_frames, ll). */
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

    /** getParcelableExtra(String, Class) es de Android 13; en Android 10-12 hay que usar la version antigua. */
    @SuppressWarnings("deprecation")
    private static Intent projectionData(Intent i) {
        return android.os.Build.VERSION.SDK_INT >= 33 ? i.getParcelableExtra("data", Intent.class)
                : (Intent) i.getParcelableExtra("data");
    }

    private void touchMarker() {
        SharedDirs.touch(this, "active");
    }

    /** La marca "active" solo existe mientras se captura; el vigilante de shell la lee. */
    private void setActive(boolean on) {
        if (on) SharedDirs.touch(this, "active");
        else SharedDirs.delete(this, "active");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (running) {
            // ya capturando: un intent sin proyeccion solo ajusta el retraso; uno con ella se ignora
            if (!intent.hasExtra("data") && delayLine != null) {
                int samples = Math.round(intent.getFloatExtra("delay_ms", 0f) * 48f);
                boolean left = intent.getBooleanExtra("left", true);
                float rampS = intent.getFloatExtra("ramp_s", 0f);
                Log.i(TAG, "retraso -> " + samples + " muestras (" + (left ? "izq" : "der") + ")"
                        + (rampS > 0 ? " en " + rampS + " s" : ""));
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
        Log.i(TAG, "afinacion: bloque=" + BLOCK + " rec=" + recFrames + " pista=" + trackFrames + " ll=" + ll);
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
        // Latencia: bloques de 5 ms y cola de salida acotada (3 bloques = 15 ms); un buffer de 1 s dejaba acumular ~80 ms.
        track.setBufferSizeInFrames(trackFrames);
        running = true;
        rec.startRecording();
        track.play();
        active = true;
        setActive(true);
        new Thread(() -> {
            android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_URGENT_AUDIO);
            int silentWhileOthers = 0;
            boolean tripped = false; // freno de seguridad activado (indicador propio: la interfaz borra `notice` al leerlo)
            short[] buf = new short[BLOCK * 2];
            // descartar lo acumulado antes de empezar: si no, esa cola se queda como retraso constante
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
                        lat = String.format(java.util.Locale.US, " latencia: captura %.0f ms + salida %.0f ms = %.0f ms (bloque %d fr, buf pista %d fr)",
                                capMs, outMs, capMs + outMs, r / 2, track.getBufferSizeInFrames());
                    }
                    int ur = track.getUnderrunCount();
                    if (ur > lastUnderruns) { // cortes: ampliar la cola un bloque (hasta 100 ms) en vez de dejar que se oigan
                        int bigger = Math.min(4800, track.getBufferSizeInFrames() + BLOCK);
                        track.setBufferSizeInFrames(bigger);
                        Log.i(TAG, "cortes en la salida: cola ampliada a " + bigger + " fr");
                        lastUnderruns = ur;
                    }
                    if (ur == lastUnderruns && track.getBufferSizeInFrames() > trackFrames
                            && now - lastUnderrunDownMs > 30000) { // 30 s sin cortes: volver a acortar la cola
                        track.setBufferSizeInFrames(Math.max(trackFrames, track.getBufferSizeInFrames() - BLOCK));
                        lastUnderrunDownMs = now;
                    }
                    if (ur > lastUnderruns) lastUnderrunDownMs = now;
                    // Freno de seguridad: si suena otra app de medios pero lo capturado es silencio, esa app bloquea la
                    // captura (p. ej. contenido protegido). Como el vigilante la tiene silenciada, no se oiria nada:
                    // se detiene la captura para que el vigilante devuelva el audio original.
                    // la API publica solo muestra el propio reproductor; el vigilante (shell) ve todos y deja el conteo en "players"
                    int others = 0;
                    try {
                        String pf = SharedDirs.readFresh(CaptureService.this, "players", 5000);
                        if (pf != null) others = Integer.parseInt(pf);
                    } catch (Exception ignored) { }
                    silentWhileOthers = (peak == 0 && others >= 1) ? silentWhileOthers + 1 : 0;
                    if (silentWhileOthers >= 6) {
                        notice = "La app que está sonando no permite procesar su audio (captura bloqueada). "
                                + "Se detuvo la alineación y se restauró el audio original.";
                        Log.w(TAG, "freno de seguridad: hay audio activo pero la captura llega en silencio");
                        tripped = true;
                        running = false;
                    }
                    Log.i(TAG, "peak=" + peak + " underruns=" + ur + " activos=" + others + " silencio=" + silentWhileOthers + lat);
                    touchMarker(); // latido: el vigilante solo silencia mientras la marca se renueve
                    peak = 0;
                    last = now;
                }
            }
            rec.stop();
            rec.release();
            track.stop();
            track.release();
            if (tripped) stopSelf(); // frenado por seguridad: liberar el servicio y la marca (onDestroy borra la marca)
        }).start();
        return START_NOT_STICKY;
    }

    @Override public void onDestroy() { running = false; active = false; setActive(false); }

    @Override public IBinder onBind(Intent i) { return null; }
}
