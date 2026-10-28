package dev.personal.caralign;

/**
 * Barrido exponencial 200-12000 Hz con ventana Hann. Reparte la energia por octava (el lineal dejaba casi
 * sin senal la zona de graves y medios bajos, que es la que decide la localizacion de una voz).
 */
final class Chirp {
    static final double F0 = 200, F1 = 12000, SEC = 0.4;

    private Chirp() {}

    /** Valor del barrido tau segundos despues de su inicio (0 fuera de [0, SEC]). */
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
