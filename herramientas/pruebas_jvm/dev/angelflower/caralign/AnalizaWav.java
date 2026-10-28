package dev.angelflower.caralign;

import java.io.RandomAccessFile;

/** Analiza offline una grabacion WAV mono 16 bit de CarAlign: SNR y ambiguedad por repeticion y banda. */
public class AnalizaWav {
    public static void main(String[] a) throws Exception {
        RandomAccessFile f = new RandomAccessFile(a[0], "r");
        byte[] b = new byte[(int) f.length()];
        f.readFully(b);
        int n = (b.length - 44) / 2;
        float[] x = new float[n];
        for (int i = 0; i < n; i++) x[i] = (short) ((b[44 + 2 * i] & 0xff) | (b[45 + 2 * i] << 8)) / 32768f;
        int reps = a.length > 1 ? Integer.parseInt(a[1]) : 10;
        Detector.Params p = TestSignal.params(48000, reps);

        float[] ref = Chirp.make(48000);
        if (a.length > 2 && a[2].equals("lineal")) { // grabaciones anteriores: barrido lineal 500-12000 Hz, 0.25 s
            int m = (int) (48000 * 0.25);
            ref = new float[m];
            for (int i = 0; i < m; i++) {
                double t = i / 48000.0, k = (12000 - 500) / 0.25;
                ref[i] = (float) ((0.5 - 0.5 * Math.cos(2 * Math.PI * t / 0.25)) * Math.sin(2 * Math.PI * (500 * t + 0.5 * k * t * t)));
            }
            p.period = (int) (1.2 * 48000);
            p.gap = (int) (0.5 * 48000);
        }
        Detector.Result r = Detector.analyze(x, n, ref, p);
        if (r.error != null) { System.out.println("error: " + r.error); return; }
        System.out.printf("ancla=%d (%.3f s) deriva=%.1f ppm%n", r.anchor, r.anchor / 48000.0, r.driftPpm);
        System.out.println("posicion de cada chirp (banda ancha) menos el calendario nominal, en ms:");
        for (int k = 0; k < reps; k++) {
            System.out.printf("   rep %d  L=%+8.3f  R=%+8.3f%n", k,
                    (r.tL[0][k] - (r.anchor + (double) k * p.period)) * 1000 / 48000,
                    (r.tR[0][k] - (r.anchor + (double) k * p.period + p.gap)) * 1000 / 48000);
        }
        double dl = 0;
        int cnt = 0;
        for (int k = 0; k < reps; k++) if (r.ok[0][k]) { dl += r.snrR[0][k] - r.snrL[0][k]; cnt++; }
        System.out.printf("NIVEL R-L (banda ancha): %+.1f dB sobre %d repeticiones%n", cnt > 0 ? dl / cnt : Double.NaN, cnt);
        for (int bd = 0; bd < Detector.NB; bd++) {
            System.out.printf("banda %-7s mediana=%+.4f ms sigma=%.1f us validas=%d%n", Detector.BAND_NAMES[bd],
                    r.medianMs[bd], r.sigmaMs[bd] * 1000, r.valid[bd]);
            for (int k = 0; k < reps; k++) {
                System.out.printf("   rep %d  snrL=%5.1f snrR=%5.1f ambL=%.2f ambR=%.2f ok=%b delta=%s%n", k,
                        r.snrL[bd][k], r.snrR[bd][k], r.ambL[bd][k], r.ambR[bd][k], r.ok[bd][k],
                        Double.isNaN(r.deltaMs[bd][k]) ? "-" : String.format("%+.4f", r.deltaMs[bd][k]));
            }
        }
    }
}
