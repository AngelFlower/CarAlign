package dev.angelflower.caralign;

/** Pruebas del retraso deslizante: exactitud, ausencia de saltos, cambio de canal. */
public class DelayTest {
    static int fails = 0, runs = 0;

    static void check(String n, boolean ok, String d) {
        runs++;
        if (!ok) fails++;
        System.out.printf("%-5s %-60s %s%n", ok ? "OK" : "FALLA", n, d);
    }

    static short[] sine(int frames, double f, double a) {
        short[] b = new short[frames * 2];
        for (int i = 0; i < frames; i++) b[2 * i] = b[2 * i + 1] = (short) Math.round(a * Math.sin(2 * Math.PI * f * i / 48000));
        return b;
    }

    public static void main(String[] args) {
        // 1) exactitud en reposo con distintos tamanos de bloque
        for (int d : new int[]{0, 1, 48, 53, 480}) {
            DelayLine dl = new DelayLine(d, true);
            int frames = 3000;
            short[] all = new short[frames * 2];
            all[20] = 1000; all[21] = 2000;
            short[] out = new short[frames * 2];
            int off = 0;
            for (int sz : new int[]{960, 480, 1560}) {
                short[] b = new short[sz * 2];
                System.arraycopy(all, off * 2, b, 0, sz * 2);
                dl.process(b, b.length);
                System.arraycopy(b, 0, out, off * 2, sz * 2);
                off += sz;
            }
            int lf = -1, rf = -1;
            for (int i = 0; i < frames; i++) { if (out[2 * i] == 1000) lf = i; if (out[2 * i + 1] == 2000) rf = i; }
            check("reposo, retraso " + d, lf - rf == d, "L en " + lf + ", R en " + rf);
        }
        // 2) rampa 0 -> 46 muestras (~0.96 ms) en 4 s: sin saltos en un seno de 1 kHz y 8 kHz
        for (double f : new double[]{1000, 8000}) {
            DelayLine dl = new DelayLine(0, true);
            dl.ramp(true, 46, 4.0);
            short[] b = sine(48000 * 5, f, 10000);
            double max = 0;
            short prev = 0;
            for (int s = 0; s < b.length; s += 960) {
                int n = Math.min(960, b.length - s);
                short[] blk = java.util.Arrays.copyOfRange(b, s, s + n);
                dl.process(blk, n);
                for (int i = 0; i < n; i += 2) { max = Math.max(max, Math.abs(blk[i] - prev)); prev = blk[i]; }
            }
            double ideal = 10000 * 2 * Math.PI * f / 48000; // maximo paso de un seno
            check(String.format("rampa 0->46 muestras, seno %.0f Hz sin saltos", f), max <= ideal * 1.15 + 2,
                    String.format("paso maximo %.0f, ideal %.0f", max, ideal));
            check("rampa termina en 46 muestras exactas", dl.current() == 46f, "actual=" + dl.current());
        }
        // 3) cambio de canal con retraso activo: el canal nuevo queda sin tocar y el viejo se libera
        {
            DelayLine dl = new DelayLine(48, true);
            short[] warm = sine(4800, 500, 8000);
            dl.process(warm, warm.length);
            dl.set(false, 24); // ahora retrasar el derecho 24 muestras
            short[] b = sine(48000, 500, 8000);
            short[] blk = java.util.Arrays.copyOf(b, b.length);
            dl.process(blk, blk.length);
            // tras estabilizar (ultima mitad), L debe ser identica a la entrada y R igual a la entrada retrasada 24
            boolean lOk = true, rOk = true;
            for (int i = 24000; i < 47000; i++) {
                if (blk[2 * i] != b[2 * i]) lOk = false;
                if (Math.abs(blk[2 * i + 1] - b[2 * (i - 24) + 1]) > 1) rOk = false;
            }
            check("cambio de canal: izquierdo libre, derecho +24", lOk && rOk, "L " + lOk + " R " + rOk);
        }
        System.out.printf("%n%d pruebas, %d fallos%n", runs, fails);
        if (fails > 0) System.exit(1);
    }
}
