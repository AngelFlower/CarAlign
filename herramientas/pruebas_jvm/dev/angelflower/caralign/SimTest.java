package dev.angelflower.caralign;

import java.util.Random;

/** Simulaciones del medidor y del lazo cerrado, sin Android. Uso: herramientas/pruebas_jvm/run.sh */
public class SimTest {
    static int fails = 0, runs = 0;
    static final int FS = 48000;

    /** Acustica simulada de un coche: retrasos aL/aR (ms), latencia comun, deriva de reloj, ruido, reflexion en R. */
    static final class Car {
        double aL, aR, latencyMs = 150, driftPpm = 0, snrDb = 40, refl = 0, reflMs = 1.5, gainR = 1, directGain = 1;
        int burstReps = 0; // repeticiones destruidas por rafagas de ruido
        int jumpFirst = 0; // primeras repeticiones con saltos de latencia de +-10 ms (arranque de Android Auto)
        long seed = 1;
    }

    static AlignLogic.Meas render(Car car, double ampDb, int reps, int dL, int dR) {
        Detector.Params p = TestSignal.params(FS, reps);
        short[] out = TestSignal.stereo(Chirp.make(FS), p, ampDb, dL, dR);
        // la simulacion rehace la secuencia con el retraso aplicado en la fuente y la acustica por canal
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
        for (int b = 0; b < car.burstReps; b++) { // rafagas fuertes sobre la repeticion b
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
        System.out.printf("%-4s %-58s %s%n", cond ? "OK" : "FALLA", name, detail);
    }

    public static void main(String[] a) throws Exception {
        // 1) precision de la medicion directa y signo: Delta = aR - aL
        double[][] cases = {{0, 2.0}, {1.5, 0}, {0, 0}, {0.35, 0}, {0, 4.2}, {2.5, 0}, {0.1, 0.12}};
        for (double[] c : cases) {
            Car car = new Car();
            car.aL = c[0]; car.aR = c[1];
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            double exp = car.aR - car.aL, got = m.det.medianMs[0];
            check(String.format("directa aL=%.2f aR=%.2f ms", car.aL, car.aR), Math.abs(got - exp) < 0.02,
                    String.format("esperado %+.4f medido %+.4f (error %+.1f us) validas=%d", exp, got, (got - exp) * 1000, m.det.valid[0]));
        }
        // 2) SNR bajo, latencia, deriva de reloj
        for (double snr : new double[]{20, 10, 5}) {
            Car car = new Car();
            car.aL = 0.4; car.aR = 1.9; car.snrDb = snr; car.latencyMs = 233.3; car.driftPpm = 80;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            double exp = 1.5, got = m.det.medianMs[0];
            check(String.format("ruido SNR=%.0f dB, latencia 233 ms, deriva 80 ppm", snr),
                    m.det.valid[0] < 5 || Math.abs(got - exp) < 0.02,
                    String.format("medido %+.4f validas=%d sigma=%.1f us deriva_est=%.1f ppm", got, m.det.valid[0], m.det.sigmaMs[0] * 1000, m.det.driftPpm));
        }
        // 3) repeticiones destruidas
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.burstReps = 2;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("2 de 8 repeticiones con rafagas de ruido", Math.abs(m.det.medianMs[0] - 1.1) < 0.03,
                    String.format("medido %+.4f validas=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 3b) saltos de latencia en las primeras repeticiones (comportamiento visto con Android Auto)
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.3; car.jumpFirst = 4; car.latencyMs = 1050; car.driftPpm = 18;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("latencia 1.05 s con saltos de +-10 ms en las 4 primeras reps", Math.abs(m.det.medianMs[0] - 1.3) < 0.02,
                    String.format("medido %+.4f validas=%d deriva=%.1f ppm", m.det.medianMs[0], m.det.valid[0], m.det.driftPpm));
        }
        // 4) reflexion en un solo lado: informativo (el maximo puede ser la reflexion)
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.refl = 0.5;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflexion -6 dB a +1.5 ms en R", Math.abs(m.det.medianMs[0] - 1.1) < 0.05,
                    String.format("medido %+.4f", m.det.medianMs[0]));
        }
        // 4b) reflexion posterior MAS FUERTE que el directo (el maximo seria la reflexion): debe elegirse el primer arribo
        {
            Car car = new Car();
            car.aL = 0; car.aR = 1.1; car.refl = 1.3; car.reflMs = 1.0; car.directGain = 0.8;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflexion 1.3x mas fuerte que el directo en R", Math.abs(m.det.medianMs[0] - 1.1) < 0.03,
                    String.format("medido %+.4f validas=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 4c) habitaculo con reflexiones fuertes en ambos lados (visto en el coche): picos 0.75 a +0.3 y +0.8 ms
        {
            Car car = new Car();
            car.aL = 3.66; car.aR = 5.02; car.refl = 0.76; car.reflMs = 0.79;
            AlignLogic.Meas m = render(car, -10, 10, 0, 0);
            check("reflexion 0.76 a +0.8 ms (como en el coche)", Math.abs(m.det.medianMs[0] - 1.36) < 0.03,
                    String.format("medido %+.4f validas=%d", m.det.medianMs[0], m.det.valid[0]));
        }
        // 5) lazo cerrado completo
        double[][] loop = {{0, 1.84}, {1.2, 0}, {0.03, 0}, {0, 3.7}, {2.6, 0.1}};
        for (double[] c : loop) {
            final Car car = new Car();
            car.aL = c[0]; car.aR = c[1]; car.snrDb = 25; car.latencyMs = 180; car.driftPpm = 30;
            AlignLogic.Out o = AlignLogic.run(
                    (amp, reps, dL, dR) -> render(car, amp, reps, dL, dR), (s, f) -> {});
            double exp = car.aR - car.aL; // x > 0 retrasa L
            check(String.format("lazo cerrado aL=%.2f aR=%.2f", car.aL, car.aR),
                    o.apply && !o.status.equals("FAIL") && Math.abs(o.xMs - exp) < 0.04,
                    String.format("estado=%s x=%+.4f (esperado %+.4f) residuo=%.1f us sigma=%.1f us banda=%s %s",
                            o.status, o.xMs, exp, o.residualMs * 1000, o.sigmaMs * 1000, o.band, o.messages));
        }
        // 6) ruido muy superior a la senal: o no aplica nada, o aplica el valor correcto (la ganancia de
        //    procesado del chirp es ~35 dB, asi que SNR -10 dB aun puede medirse bien)
        for (double snr : new double[]{-10, -25, -45}) {
            final Car car = new Car();
            car.aL = 0; car.aR = 1.0; car.snrDb = snr;
            AlignLogic.Out o = AlignLogic.run((amp, reps, dL, dR) -> render(car, amp, reps, dL, dR), (s, f) -> {});
            check(String.format("SNR %.0f dB: no aplica o aplica bien", snr), !o.apply || Math.abs(o.xMs - 1.0) < 0.05,
                    String.format("%s apply=%b x=%+.4f %s", o.status, o.apply, o.xMs, o.messages));
        }
        // 7) senal recortada
        {
            final Car car = new Car();
            car.aL = 0; car.aR = 0.8; car.snrDb = 30;
            AlignLogic.Out o = AlignLogic.run((amp, reps, dL, dR) -> {
                AlignLogic.Meas m = render(car, amp, reps, dL, dR);
                return m;
            }, (s, f) -> {});
            check("caso normal (sin recorte) converge", o.apply && Math.abs(o.xMs + 0.8 * -1) < 0.05, o.status + String.format(" x=%+.4f", o.xMs));
        }
        System.out.printf("%n%d pruebas, %d fallos%n", runs, fails);
        if (fails > 0) System.exit(1);
    }
}
