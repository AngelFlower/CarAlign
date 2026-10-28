package dev.angelflower.caralign;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.os.SystemClock;
import android.util.Log;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;

/** Una medicion real: reproduce la secuencia por la salida activa y graba con el microfono integrado. */
final class Measurer implements AlignLogic.Measure {
    private static final String TAG = "CarAlign";
    static final int FS = 48000;

    private final Context ctx;
    private final File dir;
    private final String stamp;
    private final MotionGate motion;
    private int counter;

    Measurer(Context ctx, File dir, String stamp) {
        this.ctx = ctx;
        this.dir = dir;
        this.stamp = stamp;
        this.motion = new MotionGate(ctx);
    }

    @Override
    public AlignLogic.Meas measure(double ampDb, int reps, int dL, int dR) throws Exception {
        Detector.Params p = TestSignal.params(FS, reps);
        float[] ref = Chirp.make(FS);
        short[] out = TestSignal.stereo(ref, p, ampDb, dL, dR);
        int outFrames = out.length / 2;
        int recFrames = outFrames + (int) (2.5 * FS); // la latencia de Android Auto ronda 1 s

        AudioManager am = ctx.getSystemService(AudioManager.class);
        AudioRecord rec = buildRecord(am, recFrames);
        AudioTrack tr = new AudioTrack.Builder()
                .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setAudioFormat(new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(FS).setChannelMask(AudioFormat.CHANNEL_OUT_STEREO).build())
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setBufferSizeInBytes(out.length * 2).build();
        short[] buf = new short[recFrames];
        int got = 0;
        long t0;
        String outDev, inDev;
        try {
            tr.write(out, 0, out.length);
            motion.start();
            rec.startRecording();
            t0 = SystemClock.elapsedRealtimeNanos();
            Thread.sleep(150);
            tr.play();
            long deadline = SystemClock.elapsedRealtime() + recFrames * 1000L / FS + 4000;
            while (got < recFrames && SystemClock.elapsedRealtime() < deadline) {
                int x = rec.read(buf, got, recFrames - got);
                if (x <= 0) break;
                got += x;
            }
            outDev = describe(tr.getRoutedDevice());
            inDev = describe(rec.getRoutedDevice());
        } finally {
            motion.stop();
            try { rec.stop(); } catch (Exception ignored) { }
            rec.release();
            try { tr.stop(); } catch (Exception ignored) { }
            tr.release();
        }
        if (got < recFrames * 9 / 10) throw new IOException("grabacion incompleta (" + got + "/" + recFrames + ")");

        AlignLogic.Meas m = new AlignLogic.Meas();
        m.ampDb = ampDb;
        m.outDev = outDev;
        m.inDev = inDev;
        float[] x = new float[got];
        int peak = 0;
        for (int i = 0; i < got; i++) {
            x[i] = buf[i] / 32768f;
            peak = Math.max(peak, Math.abs((int) buf[i]));
        }
        m.peak = peak / 32768.0;
        m.clipped = peak >= 31800;
        int nq = Math.min(got, (int) (0.12 * FS)); // antes de que empiece la reproduccion
        double e = 0;
        for (int i = 0; i < nq; i++) e += x[i] * (double) x[i];
        m.noiseDbfs = 20 * Math.log10(Math.max(Math.sqrt(e / Math.max(nq, 1)), 1e-9));

        m.det = Detector.analyze(x, got, ref, p);
        if (m.det.error == null) {
            boolean[] mask = new boolean[reps];
            for (int k = 0; k < reps; k++) {
                mask[k] = true;
                double tl = m.det.tL[0][k], tr2 = m.det.tR[0][k];
                long a = t0 + (long) ((tl / FS - 0.1) * 1e9), b = t0 + (long) ((tr2 / FS + 0.35) * 1e9);
                double[] st = motion.stats(a, b);
                m.maxRot = Math.max(m.maxRot, st[0]);
                m.maxAcc = Math.max(m.maxAcc, st[1]);
                if (st[0] > MotionGate.MAX_ROT || st[1] > MotionGate.MAX_ACC) {
                    mask[k] = false;
                    m.motionDiscarded++;
                }
            }
            Detector.aggregate(m.det, mask);
        }
        if (reps > 1) m.file = saveWav(buf, got);
        Log.i(TAG, String.format("medicion amp=%.0f dBFS dL=%d dR=%d ruido=%.1f dBFS pico=%.2f salida=%s entrada=%s validas=%s mediana=%s",
                ampDb, dL, dR, m.noiseDbfs, m.peak, outDev, inDev,
                m.det.error != null ? m.det.error : String.valueOf(m.det.valid[0]),
                m.det.error != null ? "-" : String.format("%+.4f ms", m.det.medianMs[0])));
        return m;
    }

    private AudioRecord buildRecord(AudioManager am, int frames) {
        AudioFormat f = new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setSampleRate(FS).setChannelMask(AudioFormat.CHANNEL_IN_MONO).build();
        AudioRecord r = null;
        for (int src : new int[]{MediaRecorder.AudioSource.UNPROCESSED, MediaRecorder.AudioSource.VOICE_RECOGNITION}) {
            try {
                AudioRecord c = new AudioRecord.Builder().setAudioSource(src).setAudioFormat(f)
                        .setBufferSizeInBytes(frames * 2).build();
                if (c.getState() == AudioRecord.STATE_INITIALIZED) { r = c; break; }
                c.release();
            } catch (Exception e) {
                Log.w(TAG, "fuente " + src + " no disponible: " + e);
            }
        }
        if (r == null) throw new IllegalStateException("no se pudo abrir el microfono");
        for (AudioDeviceInfo d : am.getDevices(AudioManager.GET_DEVICES_INPUTS)) {
            if (d.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) {
                r.setPreferredDevice(d);
                break;
            }
        }
        return r;
    }

    static String describe(AudioDeviceInfo d) {
        return d == null ? "desconocido" : d.getType() + ":" + d.getProductName();
    }

    private String saveWav(short[] pcm, int n) {
        try {
            File f = new File(dir, stamp + "_m" + (++counter) + ".wav");
            try (DataOutputStream o = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(f)))) {
                int bytes = n * 2;
                o.writeBytes("RIFF"); o.writeInt(Integer.reverseBytes(36 + bytes)); o.writeBytes("WAVEfmt ");
                o.writeInt(Integer.reverseBytes(16)); o.writeShort(Short.reverseBytes((short) 1));
                o.writeShort(Short.reverseBytes((short) 1)); o.writeInt(Integer.reverseBytes(FS));
                o.writeInt(Integer.reverseBytes(FS * 2)); o.writeShort(Short.reverseBytes((short) 2));
                o.writeShort(Short.reverseBytes((short) 16)); o.writeBytes("data"); o.writeInt(Integer.reverseBytes(bytes));
                for (int i = 0; i < n; i++) o.writeShort(Short.reverseBytes(pcm[i]));
            }
            return f.getName();
        } catch (IOException e) {
            Log.w(TAG, "no se pudo guardar el wav: " + e);
            return "";
        }
    }
}
