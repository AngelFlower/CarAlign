package dev.personal.caralign;

import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioTrack;

/** Avisos sonoros por la misma salida que la musica (el conductor no puede mirar la pantalla). */
final class Earcon {
    static final int TICK = 0, START = 1, SUCCESS = 2, FAIL = 3;
    private static final int FS = 48000;

    private Earcon() {}

    static void play(int type) {
        double[][] seq;
        switch (type) {
            case TICK: seq = new double[][]{{1000, 0.12}}; break;
            case START: seq = new double[][]{{1500, 0.40}}; break;
            case SUCCESS: seq = new double[][]{{800, 0.18}, {1200, 0.28}}; break;
            default: seq = new double[][]{{300, 0.70}}; break;
        }
        int total = 0;
        for (double[] t : seq) total += (int) (t[1] * FS) + (int) (0.04 * FS);
        short[] pcm = new short[total * 2];
        int pos = 0;
        double amp = Math.pow(10, -4 / 20.0) * 32767; // casi a fondo: el coche suele estar a volumen medio
        for (double[] t : seq) {
            int n = (int) (t[1] * FS);
            for (int i = 0; i < n; i++) {
                double env = Math.min(1, Math.min(i, n - i) / (0.01 * FS)); // rampa de 10 ms
                short v = (short) (amp * env * Math.sin(2 * Math.PI * t[0] * i / FS));
                pcm[(pos + i) * 2] = v;
                pcm[(pos + i) * 2 + 1] = v;
            }
            pos += n + (int) (0.04 * FS);
        }
        final short[] data = pcm;
        new Thread(() -> {
            try {
                AudioTrack tr = new AudioTrack.Builder()
                        .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                        .setAudioFormat(new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(FS).setChannelMask(AudioFormat.CHANNEL_OUT_STEREO).build())
                        .setBufferSizeInBytes(data.length * 2).setTransferMode(AudioTrack.MODE_STATIC).build();
                tr.write(data, 0, data.length);
                tr.play();
                Thread.sleep(data.length / 2 * 1000L / FS + 150);
                tr.release();
            } catch (Exception ignored) {
            }
        }).start();
    }
}
