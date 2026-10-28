package dev.angelflower.caralign;

import java.util.ArrayList;
import java.util.List;

/**
 * Flujo automatico (sin Android): ajusta nivel, mide, aplica y verifica en lazo cerrado.
 * Convencion: x = retraso neto en ms; x > 0 retrasa el canal izquierdo, x < 0 el derecho.
 * Un residuo r = aR - aL + (dR - dL) > 0 significa que R sigue llegando mas tarde.
 */
final class AlignLogic {
    static final double[] LADDER_DB = {-24, -18, -12, -8};
    static final double PILOT_MIN_SNR_DB = 22, MAX_AMP_DB = -6;
    static final double OK_MS = 0.04, WARN_MS = 0.10, FAIL_MS = 0.25;
    static final double MAX_SIGMA_MS = 0.15, LOW_BAND_TOL_MS = 1.0, LOW_BAND_MAX_SIGMA_MS = 0.06, MAX_DELAY_MS = 9.0;
    static final int MIN_VALID = 6, REPS = 10;

    interface Measure {
        Meas measure(double ampDb, int reps, int dL, int dR) throws Exception;
    }

    interface Progress {
        void on(String phase, float frac);
    }

    /** Resultado de una medicion con sus datos de contexto. */
    static final class Meas {
        Detector.Result det;
        double ampDb, noiseDbfs, peak, maxRot, maxAcc;
        boolean clipped;
        String outDev = "?", inDev = "?", file = "";
        int motionDiscarded;
    }

    static final class Sel {
        boolean ok;
        String why = "";
        double deltaMs, sigmaMs, broadMs, midMs, highMs;
        int valid;
        String band = "";
    }

    static final class Out {
        String status = "FAIL"; // OK, WARN, FAIL
        final List<String> messages = new ArrayList<>();
        double xMs, residualMs, sigmaMs, ampDb;
        String outDev = ""; // salida de audio vista en el primer piloto (tambien si se rechaza)
        int valid;
        String band = "";
        boolean apply;
        final List<Meas> runs = new ArrayList<>();
        final List<Sel> sels = new ArrayList<>();

        double delayLeftMs() { return apply && xMs > 0 ? xMs : 0; }
        double delayRightMs() { return apply && xMs < 0 ? -xMs : 0; }
    }

    private AlignLogic() {}

    static Sel pick(Detector.Result r) {
        Sel s = new Sel();
        if (r.error != null) { s.why = r.error; return s; }
        if (r.valid[0] < MIN_VALID) { s.why = "pocas repeticiones válidas (" + r.valid[0] + ")"; return s; }
        boolean useLow = r.valid[1] >= MIN_VALID && Math.abs(r.medianMs[1] - r.medianMs[0]) <= LOW_BAND_TOL_MS
                && r.sigmaMs[1] <= LOW_BAND_MAX_SIGMA_MS;
        int b = useLow ? 1 : 0;
        s.deltaMs = r.medianMs[b];
        s.sigmaMs = r.sigmaMs[b];
        s.valid = r.valid[b];
        s.band = Detector.BAND_NAMES[b];
        s.broadMs = r.medianMs[0];
        s.midMs = r.medianMs[2];
        s.highMs = r.medianMs[3];
        if (s.sigmaMs > MAX_SIGMA_MS) { s.why = String.format("poca repetibilidad (dispersión %.0f µs)", s.sigmaMs * 1000); return s; }
        s.ok = true;
        return s;
    }

    static Out run(Measure m, Progress prog) throws Exception {
        return run(m, prog, true);
    }

    /** allowPhoneSpeaker=false rechaza medir si la salida es el altavoz o el auricular del telefono. */
    static Out run(Measure m, Progress prog, boolean allowPhoneSpeaker) throws Exception {
        Out out = new Out();
        prog.on("Ajustando nivel", 0.05f);
        // 1) nivel de la senal: escalera de pilotos con 1 repeticion
        double amp = Double.NaN;
        for (int i = 0; i < LADDER_DB.length; i++) {
            Meas p = m.measure(LADDER_DB[i], 1, 0, 0);
            if (out.outDev.isEmpty()) out.outDev = p.outDev;
            if (!allowPhoneSpeaker && (p.outDev.startsWith("2:") || p.outDev.startsWith("1:"))) {
                out.messages.add("La salida de audio es el altavoz del teléfono, no el coche. Conecta Android Auto "
                        + "o el Bluetooth del coche y repite.");
                return out;
            }
            if (p.outDev.startsWith("7:")) { // Bluetooth SCO: linea de llamadas, mono y de baja calidad
                out.messages.add("El audio va por la línea de llamadas Bluetooth (mono, baja calidad). En el teléfono, "
                        + "Bluetooth > coche > activa \"Audio multimedia\" y vuelve a intentar.");
                return out;
            }
            double snr = Double.NaN;
            if (p.det.error == null) snr = Math.min(p.det.snrL[0][0], p.det.snrR[0][0]);
            if (snr >= PILOT_MIN_SNR_DB && !p.clipped) {
                amp = Math.min(MAX_AMP_DB, LADDER_DB[i] + 8); // audible: el SNR sobra, pero se debe oir que funciona
                break;
            }
            prog.on("Ajustando nivel", 0.05f + 0.05f * (i + 1));
        }
        if (Double.isNaN(amp)) {
            out.messages.add("No se oye bien la señal: sube el volumen del coche, cierra ventanas o reduce el ruido y repite.");
            return out;
        }
        out.ampDb = amp;

        // 2) medicion inicial
        prog.on("Midiendo", 0.30f);
        Meas m1 = m.measure(amp, REPS, 0, 0);
        if (m1.clipped) {
            amp -= 6;
            out.ampDb = amp;
            out.messages.add("La señal recortaba; se bajó el nivel de la medición.");
            m1 = m.measure(amp, REPS, 0, 0);
        }
        out.runs.add(m1);
        Sel s1 = pick(m1.det);
        out.sels.add(s1);
        if (!s1.ok) {
            out.messages.add("La medición no fue fiable: " + s1.why + ".");
            return out;
        }
        double x = clamp(s1.deltaMs);
        if (Math.abs(s1.deltaMs) > MAX_DELAY_MS) out.messages.add("La diferencia medida es muy grande; revisa la posición del teléfono.");

        // 3) verificacion en lazo cerrado (hasta 2 pasadas)
        double bestX = x, bestR = Double.POSITIVE_INFINITY;
        Sel bestSel = s1;
        for (int it = 0; it < 2; it++) {
            prog.on("Verificando", 0.55f + 0.2f * it);
            int dL = x > 0 ? (int) Math.round(x * 48) : 0, dR = x < 0 ? (int) Math.round(-x * 48) : 0;
            Meas v = m.measure(amp, REPS, dL, dR);
            out.runs.add(v);
            Sel sv = pick(v.det);
            out.sels.add(sv);
            if (!sv.ok) {
                out.messages.add("La verificación no fue fiable: " + sv.why + ".");
                break;
            }
            double r = sv.deltaMs;
            if (Math.abs(r) < bestR) { bestR = Math.abs(r); bestX = x; bestSel = sv; }
            if (Math.abs(r) <= OK_MS) break;
            x = clamp(x + r);
        }
        if (Double.isInfinite(bestR)) {
            out.messages.add("No se pudo verificar el ajuste, por eso no se aplica.");
            return out;
        }
        // L y R practicamente identicos en tiempo y nivel: salida mono, o coche ya alineado
        Detector.Result d0 = out.runs.get(0).det;
        double snrDiff = 0;
        int cnt = 0;
        for (int k = 0; k < d0.snrL[0].length; k++) {
            if (d0.ok[0][k]) { snrDiff += Math.abs(d0.snrL[0][k] - d0.snrR[0][k]); cnt++; }
        }
        if (Math.abs(s1.deltaMs) < 0.010 && cnt > 0 && snrDiff / cnt < 0.5) {
            out.messages.add("Izquierdo y derecho suenan idénticos (misma llegada y mismo nivel). Si no lo esperabas, "
                    + "la salida puede ser mono o mezclada; revisa balance, fader y que el audio sea estéreo.");
        }
        out.xMs = bestX;
        out.residualMs = bestR;
        out.sigmaMs = bestSel.sigmaMs;
        out.valid = bestSel.valid;
        out.band = s1.band;
        if (bestR <= OK_MS) out.status = "OK";
        else if (bestR <= WARN_MS) out.status = "WARN";
        else if (bestR <= FAIL_MS) {
            out.status = "WARN";
            out.messages.add("El ajuste no converge del todo; queda un residuo de " + Math.round(bestR * 1000) + " us.");
        } else {
            out.messages.add("El ajuste no converge (residuo " + Math.round(bestR * 1000) + " us); no se aplica.");
            return out;
        }
        out.apply = true;
        return out;
    }

    private static double clamp(double x) {
        return Math.max(-MAX_DELAY_MS, Math.min(MAX_DELAY_MS, x));
    }
}
