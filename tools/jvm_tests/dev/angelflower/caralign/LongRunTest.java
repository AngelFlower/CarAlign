package dev.angelflower.caralign;

/**
 * Long-duration delay test: simulates minutes of 48 kHz audio and checks the output is still the input delayed by
 * exactly N samples (a 5 kHz sine makes any delay jitter visible).
 */
public class LongRunTest {
    static int in(long n) {
        return (int) Math.round(10000 * Math.sin(2 * Math.PI * 5000.0 * (n % 48000) / 48000.0));
    }

    public static void main(String[] a) {
        int delay = 46, block = 960;
        DelayLine dl = new DelayLine(delay, true);
        short[] buf = new short[block * 2];
        long frame = 0;
        long[] checkMin = {1, 4, 6, 8, 10, 15, 20, 30, 45, 60};
        int ci = 0;
        boolean ok = true;
        long t0 = System.nanoTime();
        while (ci < checkMin.length) {
            for (int i = 0; i < block; i++) {
                buf[2 * i] = (short) in(frame + i);
                buf[2 * i + 1] = (short) in(frame + i);
            }
            dl.process(buf, buf.length);
            if (frame >= checkMin[ci] * 60L * 48000L) { // check one block at each minute milestone
                int bad = 0;
                double maxErr = 0;
                for (int i = 0; i < block; i++) {
                    int expL = (frame + i) < delay ? 0 : in(frame + i - delay);
                    int errL = Math.abs(buf[2 * i] - expL);
                    maxErr = Math.max(maxErr, errL);
                    if (errL > 1) bad++;
                    if (buf[2 * i + 1] != in(frame + i)) bad += 1000; // the undelayed channel must stay intact
                }
                System.out.printf("%3d min: wrong samples %4d/%d, max error %.0f  %s%n", checkMin[ci], bad, block, maxErr,
                        bad == 0 ? "OK" : "FAIL");
                if (bad > 0) ok = false;
                ci++;
            }
            frame += block;
        }
        System.out.printf("%.1f s of computation for %d minutes of audio%n", (System.nanoTime() - t0) / 1e9, checkMin[checkMin.length - 1]);
        if (!ok) System.exit(1);
    }
}
