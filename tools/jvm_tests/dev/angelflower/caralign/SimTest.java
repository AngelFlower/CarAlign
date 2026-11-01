package dev.angelflower.caralign;

import java.util.Random;

/** Simulations of the meter and the closed loop, without Android. Usage: tools/jvm_tests/run.sh */
public class SimTest {
    static int fails = 0, runs = 0;
    static final int FS = 48000;

    /** Simulated car acoustics: delays aL/aR (ms), common latency, clock drift, noise, reflection on R. */
    static final class Car {
        double aL, aR, latencyMs = 150, driftPpm = 0, snrDb = 40, refl = 0, reflMs = 1.5, gainR = 1, directGain = 1;
        int burstReps = 0; // repetitions destroyed by noise bursts
        int jumpFirst = 0; // first repetitions with +-10 ms latency jumps (Android Auto start-up)
        long seed = 1;
    }

    static AlignLogic.Meas render(Car car, double ampDb, int reps, int dL, int dR) {
        Detector.Params p = TestSignal.params(FS, reps);
        short[] out = TestSignal.stereo(Chirp.make(FS), p, ampDb, dL, dR);
        // the simulation rebuilds the sequence with the delay applied at the source and the acoustics per channel
        int lead = p.lead;
        int total = out.length / 2 + (int) (2.5 * FS);
        float[] rec = new float[total];
        double amp = Math.pow(10, ampDb / 20);
        double drift = 1 + car.driftPpm * 1e-6;
        for (int k = 0; k < reps; k++) {
            for (int side = 0; side < 2; side++) {
                double a = side == 0 ? car.aL : car.aR;
                double nominal = lead + k * p.period + (side == 1 ? p.gap : 0) + (side == 0 ? dL : dR);
                double jump = k < car.jumpFirst ? (((k * 7 + side * 3) % 5) - 2) * 5.0 : 0; // 0, +-5, +-10 ms
                double start = (nominal + (a + car.latencyMs + jump) * FS / 1000.0) * drift;
                double g = side == 1 ? car.gainR : 1;
                add(rec, start, amp * g * (side == 1 ? car.directGain : 1));
                if (side == 1 && car.refl > 0) add(rec, start + car.reflMs * FS / 1000.0, amp * g * car.refl);
            }
        }
        Random rnd = new Random(car.seed + (long) (ampDb * 7) + dL * 31L + dR * 17L + reps);
        double sigma = 0.433 * amp / Math.pow(10, car.snrDb / 20);
        for (int i = 0; i < total; i++) rec[i] += (float) (rnd.nextGaussian() * sigma);
        for (int b = 0; b < car.burstReps; b++) { // strong bursts over repetition b
            int s0 = (int) ((lead + b * p.period) * drift + car.latencyMs * FS / 1000.0);
            for (int i = 0; i < (int) (1.1 * FS) && s0 + i < total; i++) rec[s0 + i] += (float) (rnd.nextGaussian() * 5 * amp);
        }
        AlignLogic.Meas m = new AlignLogic.Meas();
        m.ampDb = ampDb;
        double pk = 0;
        for (float v : rec) pk = Math.max(pk, Math.abs(v));
        m.peak = pk;
        m.clipped = pk > 0.97;
        m.det = Detector.analyze(rec, total, Chirp.make(FS), p);
        return m;
    }

    static void add(float[] rec, double start, double amp) {
        int i0 = (int) Math.ceil(start), n = (int) (Chirp.SEC * FS);
        for (int j = i0; j < start + n && j < rec.length; j++) {
            if (j >= 0) rec[j] += (float) (amp * Chirp.valueAt((j - start) / FS));
        }
    }

    static void check(String name, boolean cond, String detail) {
        runs++;
        if (!cond) fails++;
        System.out.printf("%-4s %-58s %s%n", cond ? "OK" : "FAIL", name, detail);
    }

    public static void main(String[] a) throws Exception {
        // 1) accuracy of the direct measurement and its sign: Delta = aR - aL
        double[][] cases = {{0, 2.0}, {1.5, 0}, {0, 0}, {0.35, 0}, {0, 4.2}, {2.5, 0}, {0.1, 0.12}};
        for (double[] c : cases) {
            Car car = new Car();
            car.aL = c[0]; car.aR = c[1];
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            double exp = car.aR - car.aL, got = m.det.medianMs[0];
            check(String.format("direct aL=%.2f aR=%.2f ms", car.aL, car.aR), Math.abs(got - exp) < 0.02,
                    String.format("expected %+.4f measured %+.4f (error %+.1f us) valid=%d", exp, got, (got - exp) * 1000, m.det.valid[0]));
        }
        // 2) low SNR, latency, clock drift
        for (double snr : new double[]{20, 10, 5}) {
            Car car = new Car();
            car.aL = 0.4; car.aR = 1.9; car.snrDb = snr; car.latencyMs = 233.3; car.driftPpm = 80;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            double exp = 1.5, got = m.det.medianMs[0];
            check(String.format("noise SNR=%.0f dB, latency 233 ms, drift 80 ppm", snr),
                    m.det.valid[0] < 5 || Math.abs(got - exp) < 0.02,
                    String.format("measured %+.4f valid=%d sigma=%.1f us est_drift=%.1f ppm", got, m.det.valid[0], m.det.sigmaMs[0] * 1000, m.det.driftPpm));
        }
        // 3) destroyed repetitions
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.burstReps = 2;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("2 of 8 repetitions with noise bursts", Math.abs(m.det.medianMs[0] - 1.1) < 0.03,
                    String.format("measured %+.4f valid=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 3b) latency jumps in the first repetitions (behavior seen with Android Auto)
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.3; car.jumpFirst = 4; car.latencyMs = 1050; car.driftPpm = 18;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("latency 1.05 s with +-10 ms jumps in the first 4 reps", Math.abs(m.det.medianMs[0] - 1.3) < 0.02,
                    String.format("measured %+.4f valid=%d drift=%.1f ppm", m.det.medianMs[0], m.det.valid[0], m.det.driftPpm));
        }
        // 4) reflection on one side only: informative (the maximum may be the reflection)
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.refl = 0.5;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflection -6 dB at +1.5 ms on R", Math.abs(m.det.medianMs[0] - 1.1) < 0.05,
                    String.format("measured %+.4f", m.det.medianMs[0]));
        }
        // 4b) a later reflection STRONGER than the direct sound (the maximum would be the reflection): the first arrival must be chosen
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.refl = 1.3; car.reflMs = 1.0; car.directGain = 0.8;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflection 1.3x stronger than the direct sound on R", Math.abs(m.det.medianMs[0] - 1.1) < 0.03,
                    String.format("measured %+.4f valid=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 4c) cabin with strong reflections on both sides (seen in the car): peaks 0.75 at +0.3 and +0.8 ms
        {
            Car car = new Car();
            car.aL = 3.66; car.aR = 5.02; car.refl = 0.76; car.reflMs = 0.79;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflection 0.76 at +0.8 ms (as in the car)", Math.abs(m.det.medianMs[0] - 1.36) < 0.03,
                    String.format("measured %+.4f valid=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 5) full closed loop
        double[][] loop = {{0, 1.84}, {1.2, 0}, {0.03, 0}, {0, 3.7}, {2.6, 0.1}};
        for (double[] c : loop) {
            final Car car = new Car();
            car.aL = c[0]; car.aR = c[1]; car.snrDb = 25; car.latencyMs = 180; car.driftPpm = 30;
            AlignLogic.Out o = AlignLogic.run(
                    (amp, reps, dL, dR) -> render(car, amp, reps, dL, dR), (s, f) -> {});
            double exp = car.aR - car.aL; // x > 0 delays L
            check(String.format("closed loop aL=%.2f aR=%.2f", car.aL, car.aR),
                    o.apply && !o.status.equals("FAIL") && Math.abs(o.xMs - exp) < 0.04,
                    String.format("state=%s x=%+.4f (expected %+.4f) residual=%.1f us sigma=%.1f us band=%s %s",
                            o.status, o.xMs, exp, o.residualMs * 1000, o.sigmaMs * 1000, o.band, o.messages));
        }
        // 6) noise far above the signal: either nothing is applied, or the correct value is (the chirp's
        //    processing gain is ~35 dB, so an SNR of -10 dB can still be measured well)
        for (double snr : new double[]{-10, -25, -45}) {
            final Car car = new Car();
            car.aL = 0; car.aR = 1.0; car.snrDb = snr;
            AlignLogic.Out o = AlignLogic.run((amp, reps, dL, dR) -> render(car, amp, reps, dL, dR), (s, f) -> {});
            check(String.format("SNR %.0f dB: applies nothing or applies correctly", snr), !o.apply || Math.abs(o.xMs - 1.0) < 0.05,
                    String.format("%s apply=%b x=%+.4f %s", o.status, o.apply, o.xMs, o.messages));
        }
        // 7) clipped signal
        {
            final Car car = new Car();
            car.aL = 0; car.aR = 0.8; car.snrDb = 30;
            AlignLogic.Out o = AlignLogic.run((amp, reps, dL, dR) -> {
                AlignLogic.Meas m = render(car, amp, reps, dL, dR);
                return m;
            }, (s, f) -> {});
            check("normal case (no clipping) converges", o.apply && Math.abs(o.xMs + 0.8 * -1) < 0.05, o.status + String.format(" x=%+.4f", o.xMs));
        }
        System.out.printf("%n%d tests, %d failures%n", runs, fails);
        if (fails > 0) System.exit(1);
    }
}
