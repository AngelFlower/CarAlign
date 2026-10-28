package dev.angelflower.caralign;

import java.util.Arrays;

/**
 * Analisis puro (sin Android) de una grabacion con la secuencia L,R,L,R... de chirps.
 * Mide la llegada de cada chirp por correlacion cruzada (envolvente analitica, interpolacion
 * parabolica) en banda ancha y en tres bandas, y devuelve la diferencia R-L por repeticion.
 */
final class Detector {
    static final double[][] BANDS = {{200, 12000}, {200, 1000}, {1000, 4000}, {4000, 12000}};
    static final String[] BAND_NAMES = {"ancha", "graves", "medios", "agudos"};
    static final int NB = BANDS.length;

    static final class Params {
        int fs = 48000, reps = 8, period, gap, lead;
        double minSnrDb = 12, maxAmbiguity = 0.9, firstArrival = 0.5;
    }

    static final class Result {
        String error;
        int anchor;
        double driftPpm; // deriva reproduccion/captura estimada (ppm)
        double[][] tL, tR, snrL, snrR, ambL, ambR; // [banda][rep], muestras / dB / razon
        boolean[][] ok;
        double[][] deltaMs;                          // [banda][rep] = aR - aL en ms, NaN si no valida
        double[] medianMs = new double[NB], sigmaMs = new double[NB];
        int[] valid = new int[NB];
    }

    private Detector() {}

    static Result analyze(float[] rec, int len, float[] ref, Params p) {
        Result r = new Result();
        int span = (p.reps - 1) * p.period + p.gap;
        if (len < span + ref.length + p.fs / 2) {
            r.error = "grabación demasiado corta";
            return r;
        }
        int n = Fft.nextPow2(len + ref.length);
        double[] xr = new double[n], xi = new double[n];
        for (int i = 0; i < len; i++) xr[i] = rec[i];
        Fft.transform(xr, xi, false);
        double[] cr = new double[n], ci = new double[n];
        for (int i = 0; i < ref.length; i++) cr[i] = ref[i];
        Fft.transform(cr, ci, false);
        for (int i = 0; i < n; i++) { // X * conj(C)
            double a = xr[i], b = xi[i];
            xr[i] = a * cr[i] + b * ci[i];
            xi[i] = b * cr[i] - a * ci[i];
        }
        float[][] env = new float[NB][];
        float[] med = new float[NB];
        for (int b = 0; b < NB; b++) {
            env[b] = envelope(xr, xi, cr, ci, n, p.fs, BANDS[b][0], BANDS[b][1], len);
            med[b] = median(env[b], len);
        }
        if (!(med[0] > 0)) {
            r.error = "grabación en silencio";
            return r;
        }

        // 1) calendario: desplazamiento T que maximiza la suma de la envolvente en las 2*reps posiciones esperadas
        int w = (int) (0.008 * p.fs);
        float[] lm = slidingMax(env[0], len, w);
        int tMax = len - 1 - span;
        double best = -1;
        int bestT = 0;
        for (int t = 0; t <= tMax; t++) {
            double s = 0;
            for (int k = 0; k < p.reps; k++) s += lm[t + k * p.period] + lm[t + k * p.period + p.gap];
            if (s > best) { best = s; bestT = t; }
        }
        r.anchor = bestT;

        // 2) pasada 1 (ancha, +-20 ms): re-centrar L y R por separado con la mediana de los desvios
        int w1 = (int) (0.020 * p.fs);
        double[] offL = new double[p.reps], offR = new double[p.reps];
        for (int k = 0; k < p.reps; k++) {
            int eL = bestT + k * p.period, eR = eL + p.gap;
            offL[k] = argmax(env[0], len, eL, w1) - eL;
            offR[k] = argmax(env[0], len, eR, w1) - eR;
        }
        // grupo de posiciones mas repetido (un salto de latencia de Android Auto no debe desplazar el centro)
        double oL = clusterCenter(offL, (int) (0.0015 * p.fs)), oR = clusterCenter(offR, (int) (0.0015 * p.fs));

        // 3) pasada 2 por banda (+-6 ms alrededor del centro re-centrado)
        int w2 = (int) (0.003 * p.fs), wAmb = (int) (0.012 * p.fs), excl = (int) (0.0015 * p.fs);
        r.tL = new double[NB][p.reps]; r.tR = new double[NB][p.reps];
        r.snrL = new double[NB][p.reps]; r.snrR = new double[NB][p.reps];
        r.ambL = new double[NB][p.reps]; r.ambR = new double[NB][p.reps];
        r.ok = new boolean[NB][p.reps];
        r.deltaMs = new double[NB][p.reps];
        for (int b = 0; b < NB; b++) {
            for (int k = 0; k < p.reps; k++) {
                int eL = (int) Math.round(bestT + k * p.period + oL);
                int eR = (int) Math.round(bestT + k * p.period + p.gap + oR);
                double[] a = peak(env[b], len, eL, w2, wAmb, excl, med[b], p.firstArrival);
                double[] c = peak(env[b], len, eR, w2, wAmb, excl, med[b], p.firstArrival);
                r.tL[b][k] = a[0]; r.snrL[b][k] = a[1]; r.ambL[b][k] = a[2];
                r.tR[b][k] = c[0]; r.snrR[b][k] = c[1]; r.ambR[b][k] = c[2];
                r.ok[b][k] = a[1] >= p.minSnrDb && c[1] >= p.minSnrDb
                        && a[2] < p.maxAmbiguity && c[2] < p.maxAmbiguity;
            }
        }
        // deriva entre el reloj de reproduccion y el de captura: estira el hueco L->R (gap) y sesga la
        // diferencia; se estima con la pendiente de las posiciones de la banda ancha frente al calendario
        double f = driftFactor(r, p);
        r.driftPpm = (f - 1) * 1e6;
        for (int b = 0; b < NB; b++) {
            for (int k = 0; k < p.reps; k++) {
                r.deltaMs[b][k] = r.ok[b][k]
                        ? ((r.tR[b][k] - r.tL[b][k]) - p.gap * f) * 1000.0 / p.fs : Double.NaN;
            }
        }
        aggregate(r, null);
        return r;
    }

    /** Mediana, sigma robusta (MAD) y numero de repeticiones validas por banda; mask opcional (movimiento). */
    static void aggregate(Result r, boolean[] mask) {
        for (int b = 0; b < NB; b++) {
            int reps = r.deltaMs[b].length;
            double[] v = new double[reps];
            int m = 0;
            for (int k = 0; k < reps; k++) {
                if (!Double.isNaN(r.deltaMs[b][k]) && (mask == null || mask[k])) v[m++] = r.deltaMs[b][k];
            }
            r.valid[b] = m;
            if (m == 0) { r.medianMs[b] = Double.NaN; r.sigmaMs[b] = Double.NaN; continue; }
            double[] x = Arrays.copyOf(v, m);
            double med = medianOf(x);
            double[] dev = new double[m];
            for (int i = 0; i < m; i++) dev[i] = Math.abs(x[i] - med);
            r.medianMs[b] = med;
            r.sigmaMs[b] = 1.4826 * medianOf(dev);
        }
    }

    /** 1 + deriva: pendiente media (L y R) de la posicion de cada chirp respecto al periodo nominal. */
    private static double driftFactor(Result r, Params p) {
        double sum = 0;
        int n = 0;
        for (int side = 0; side < 2; side++) {
            double[] t = side == 0 ? r.tL[0] : r.tR[0];
            double sx = 0, sy = 0, sxx = 0, sxy = 0;
            int m = 0;
            for (int k = 0; k < p.reps; k++) {
                if (!r.ok[0][k]) continue;
                sx += k; sy += t[k]; sxx += (double) k * k; sxy += k * t[k]; m++;
            }
            if (m < 4) continue;
            double den = m * sxx - sx * sx;
            if (den <= 0) continue;
            sum += (m * sxy - sx * sy) / den / p.period;
            n++;
        }
        if (n == 0) return 1;
        double f = sum / n;
        return Math.abs(f - 1) > 500e-6 ? 1 : f; // fuera de lo plausible: no corregir
    }

    // ---- utilidades ----

    private static float[] envelope(double[] sr, double[] si, double[] yr, double[] yi, int n, int fs,
                                    double lo, double hi, int len) {
        double df = (double) fs / n;
        for (int i = 0; i < n; i++) {
            if (i <= n / 2) {
                double m = mask(i * df, lo, hi) * ((i == 0 || i == n / 2) ? 1 : 2); // senal analitica
                yr[i] = sr[i] * m;
                yi[i] = si[i] * m;
            } else {
                yr[i] = 0;
                yi[i] = 0;
            }
        }
        Fft.transform(yr, yi, true);
        float[] e = new float[len];
        for (int t = 0; t < len; t++) e[t] = (float) Math.hypot(yr[t], yi[t]);
        return e;
    }

    private static double mask(double f, double lo, double hi) {
        double rl = 0.3 * lo, rh = 0.15 * hi;
        if (f <= lo - rl || f >= hi + rh) return 0;
        if (f < lo) return 0.5 - 0.5 * Math.cos(Math.PI * (f - (lo - rl)) / rl);
        if (f <= hi) return 1;
        return 0.5 + 0.5 * Math.cos(Math.PI * (f - hi) / rh);
    }

    private static float median(float[] e, int len) {
        int stride = 8;
        float[] s = new float[len / stride];
        for (int i = 0; i < s.length; i++) s[i] = e[i * stride];
        Arrays.sort(s);
        return s[s.length / 2];
    }

    /** Centro (media) del grupo de valores con mas vecinos a +-tol; desempata por el primero. */
    private static double clusterCenter(double[] v, int tol) {
        int best = -1, bestN = -1;
        for (int i = 0; i < v.length; i++) {
            int n = 0;
            for (double u : v) if (Math.abs(u - v[i]) <= tol) n++;
            if (n > bestN) { bestN = n; best = i; }
        }
        double sum = 0;
        int n = 0;
        for (double u : v) if (Math.abs(u - v[best]) <= tol) { sum += u; n++; }
        return sum / n;
    }

    private static double medianOf(double[] x) {
        double[] s = x.clone();
        Arrays.sort(s);
        int n = s.length;
        return n % 2 == 1 ? s[n / 2] : 0.5 * (s[n / 2 - 1] + s[n / 2]);
    }

    private static float[] slidingMax(float[] e, int len, int w) {
        float[] out = new float[len];
        int[] dq = new int[len];
        int h = 0, tl = 0;
        for (int i = 0; i < len + w; i++) {
            if (i < len) {
                while (tl > h && e[dq[tl - 1]] <= e[i]) tl--;
                dq[tl++] = i;
            }
            int c = i - w;
            if (c >= 0) {
                while (dq[h] < c - w) h++;
                out[c] = e[dq[h]];
            }
        }
        return out;
    }

    private static int argmax(float[] e, int len, int center, int w) {
        int lo = Math.max(1, center - w), hi = Math.min(len - 2, center + w);
        int bi = lo;
        for (int i = lo; i <= hi; i++) if (e[i] > e[bi]) bi = i;
        return bi;
    }

    /**
     * {posicion sub-muestra, SNR del pico en dB respecto a la mediana, razon pico-previo / pico}.
     * Toma el PRIMER arribo: el maximo del entorno, o un pico anterior (hasta 3 ms antes) que alcance al menos
     * `first` veces el maximo. En un habitaculo las reflexiones posteriores pueden ser casi tan fuertes como el
     * sonido directo y no deben invalidar la medicion; solo importa que no haya un pico anterior comparable.
     */
    private static double[] peak(float[] e, int len, int center, int w, int wAmb, int excl, float median, double first) {
        int i = argmax(e, len, center, w);
        double top = e[i];
        int back = (int) (0.003 * 48000);
        for (int j = Math.max(2, i - back); j < i; j++) {
            boolean localMax = e[j] >= e[j - 1] && e[j] >= e[j + 1] && e[j] >= e[j - 2] && e[j] >= e[j + 2];
            if (localMax && e[j] >= first * top) { i = j; break; } // el mas temprano que cumple
        }
        double a = e[i - 1], b = e[i], c = e[i + 1];
        double d = a - 2 * b + c;
        double pos = d == 0 ? i : i + 0.5 * (a - c) / d;
        double snr = 20 * Math.log10(Math.max(top, 1e-12) / Math.max(median, 1e-12));
        // mayor MAXIMO LOCAL previo (queda < first por construccion). Solo cuentan maximos locales: en una banda
        // estrecha el pico es ancho y su propia falda no es un arribo anterior.
        double earlier = 0;
        for (int j = Math.max(2, i - back); j < i; j++) {
            boolean localMax = e[j] >= e[j - 1] && e[j] >= e[j + 1] && e[j] >= e[j - 2] && e[j] >= e[j + 2];
            if (localMax && e[j] > earlier) earlier = e[j];
        }
        return new double[]{pos, snr, b > 0 ? earlier / b : 0};
    }
}
