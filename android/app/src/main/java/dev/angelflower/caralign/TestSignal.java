package dev.angelflower.caralign;

/** Secuencia de medicion: por repeticion un chirp solo en L y, `gap` muestras despues, uno solo en R. */
final class TestSignal {
    static final double PILOT_LEAD_S = 2.0, LEAD_S = 3.0, PERIOD_S = 1.6, GAP_S = 0.7, TAIL_S = 0.8; // gap != period/2: evita confundir L con R
    /** El piloto tambien lleva calentamiento: un enlace Bluetooth dormido tarda en despertar y se come el inicio. */
    /** Cama de ruido bajisimo durante el calentamiento: mantiene activo el flujo de Android Auto/Bluetooth. */
    static final double BED_DB_BELOW = 28, BED_END_BEFORE_S = 0.4;

    private TestSignal() {}

    static Detector.Params params(int fs, int reps) {
        Detector.Params p = new Detector.Params();
        p.fs = fs;
        p.reps = reps;
        p.period = (int) (PERIOD_S * fs);
        p.gap = (int) (GAP_S * fs);
        p.lead = (int) ((reps > 1 ? LEAD_S : PILOT_LEAD_S) * fs);
        return p;
    }

    /**
     * Estereo entrelazado en 16 bits. dL y dR retrasan el chirp de cada canal en muestras:
     * es lo mismo que aplicar el retraso a la corriente (sirve para verificar en lazo cerrado).
     */
    static short[] stereo(float[] ref, Detector.Params p, double ampDbfs, int dL, int dR) {
        int lead = p.lead, tail = (int) (TAIL_S * p.fs);
        int total = lead + (p.reps - 1) * p.period + p.gap + ref.length + tail + Math.max(dL, dR);
        short[] out = new short[total * 2];
        double a = Math.pow(10, ampDbfs / 20) * 32767;
        if (lead > p.fs * 1.5) { // calentamiento: ruido decorrelado por canal, sin tocar la zona de los chirps
            java.util.Random rnd = new java.util.Random(12345);
            double bed = Math.pow(10, (ampDbfs - BED_DB_BELOW) / 20) * 32767 * 0.3;
            int end = lead - (int) (BED_END_BEFORE_S * p.fs);
            for (int i = 0; i < end; i++) {
                out[i * 2] = (short) Math.round(rnd.nextGaussian() * bed);
                out[i * 2 + 1] = (short) Math.round(rnd.nextGaussian() * bed);
            }
        }
        for (int k = 0; k < p.reps; k++) {
            int pl = lead + k * p.period + dL;
            int pr = lead + k * p.period + p.gap + dR;
            for (int i = 0; i < ref.length; i++) {
                short v = (short) Math.round(ref[i] * a);
                out[(pl + i) * 2] = v;
                out[(pr + i) * 2 + 1] = v;
            }
        }
        return out;
    }
}
