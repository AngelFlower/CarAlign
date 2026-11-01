package dev.angelflower.caralign;

/** Tests of the sliding delay: accuracy, absence of jumps, channel switching. */
public class DelayTest {
    static int fails = 0, runs = 0;

    static void check(String n, boolean ok, String d) {
        runs++;
        if (!ok) fails++;
        System.out.printf("%-5s %-60s %s%n", ok ? "OK" : "FAIL", n, d);
    }

    static short[] sine(int frames, double f, double a) {
        short[] b = new short[frames * 2];
        for (int i = 0; i < frames; i++) b[2 * i] = b[2 * i + 1] = (short) Math.round(a * Math.sin(2 * Math.PI * f * i / 48000));
        return b;
    }

    public static void main(String[] args) {
        // 1) accuracy at rest with different block sizes
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
            check("at rest, delay " + d, lf - rf == d, "L at " + lf + ", R at " + rf);
        }
        // 2) ramp 0 -> 46 samples (~0.96 ms) over 4 s: no jumps in a 1 kHz and 8 kHz sine
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
            double ideal = 10000 * 2 * Math.PI * f / 48000; // maximum step of a sine
            check(String.format("ramp 0->46 samples, %.0f Hz sine without jumps", f), max <= ideal * 1.15 + 2,
                    String.format("max step %.0f, ideal %.0f", max, ideal));
            check("ramp ends at exactly 46 samples", dl.current() == 46f, "current=" + dl.current());
        }
        // 3) channel switch with an active delay: the new channel is left untouched and the old one is released
        {
            DelayLine dl = new DelayLine(48, true);
            short[] warm = sine(4800, 500, 8000);
            dl.process(warm, warm.length);
            dl.set(false, 24); // now delay the right channel by 24 samples
            short[] b = sine(48000, 500, 8000);
            short[] blk = java.util.Arrays.copyOf(b, b.length);
            dl.process(blk, blk.length);
            // after settling (second half), L must equal the input and R the input delayed by 24
            boolean lOk = true, rOk = true;
            for (int i = 24000; i < 47000; i++) {
                if (blk[2 * i] != b[2 * i]) lOk = false;
                if (Math.abs(blk[2 * i + 1] - b[2 * (i - 24) + 1]) > 1) rOk = false;
            }
            check("channel switch: left free, right +24", lOk && rOk, "L " + lOk + " R " + rOk);
        }
        System.out.printf("%n%d tests, %d failures%n", runs, fails);
        if (fails > 0) System.exit(1);
    }
}
