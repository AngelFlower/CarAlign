package dev.angelflower.caralign;

/**
 * Exponential sweep 200-12000 Hz with a Hann window. It spreads energy per octave (a linear sweep left almost
 * no signal in the bass and low-mid region, which is what decides the localization of a voice).
 */
final class Chirp {
    static final double F0 = 200, F1 = 12000, SEC = 0.4;

    private Chirp() {}

    /** Sweep value tau seconds after its start (0 outside [0, SEC]). */
    static double valueAt(double tau) {
        if (tau < 0 || tau > SEC) return 0;
        double k = Math.log(F1 / F0);
        double w = 0.5 - 0.5 * Math.cos(2 * Math.PI * tau / SEC);
        return w * Math.sin(2 * Math.PI * F0 * SEC / k * (Math.exp(tau * k / SEC) - 1));
    }

    static float[] make(int fs) {
        int n = (int) (fs * SEC);
        float[] x = new float[n];
        for (int i = 0; i < n; i++) x[i] = (float) valueAt(i / (double) fs);
        return x;
    }
}
