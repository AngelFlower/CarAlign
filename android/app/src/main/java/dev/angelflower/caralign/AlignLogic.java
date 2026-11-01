package dev.angelflower.caralign;

import java.util.ArrayList;
import java.util.List;

/**
 * Automatic flow (no Android): sets the level, measures, applies and verifies in a closed loop.
 * Convention: x = net delay in ms; x > 0 delays the left channel, x < 0 the right one.
 * A residual r = aR - aL + (dR - dL) > 0 means R still arrives later.
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

    /** Phase codes reported to the UI (the Flutter layer localizes them). */
    static final String PREPARING = "preparing", ADJUSTING_LEVEL = "adjustingLevel", MEASURING = "measuring",
            VERIFYING = "verifying", STOPPING_CAPTURE = "stoppingCapture", DONE = "done";

    /** A user-facing note identified by a code; the Flutter layer turns it into text. */
    static final class Msg {
        final String code, reason, text;
        final double value;

        Msg(String code, String reason, double value, String text) {
            this.code = code;
            this.reason = reason;
            this.value = value;
            this.text = text;
        }

        static Msg of(String code) { return new Msg(code, null, 0, null); }

        static Msg withValue(String code, double value) { return new Msg(code, null, value, null); }

        /** A message whose cause is the failure described by `s`. */
        static Msg because(String code, Sel s) { return new Msg(code, s.why, s.whyValue, null); }

        static Msg text(String code, String text) { return new Msg(code, null, 0, text); }

        @Override public String toString() { return code + (reason != null ? "(" + reason + ")" : ""); }
    }

    /** Result of one measurement with its context data. */
    static final class Meas {
        Detector.Result det;
        double ampDb, noiseDbfs, peak, maxRot, maxAcc;
        boolean clipped;
        String outDev = "?", inDev = "?", file = "";
        int motionDiscarded;
    }

    static final class Sel {
        boolean ok;
        String why = ""; // reason code when !ok
        double whyValue;
        double deltaMs, sigmaMs, broadMs, midMs, highMs;
        int valid;
        String band = "";
    }

    static final class Out {
        String status = "FAIL"; // OK, WARN, FAIL
        final List<Msg> messages = new ArrayList<>();
        double xMs, residualMs, sigmaMs, ampDb;
        String outDev = ""; // audio output seen by the first pilot (also when rejected)
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
        if (r.valid[0] < MIN_VALID) { s.why = "fewValidReps"; s.whyValue = r.valid[0]; return s; }
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
        if (s.sigmaMs > MAX_SIGMA_MS) { s.why = "lowRepeatability"; s.whyValue = s.sigmaMs * 1000; return s; }
        s.ok = true;
        return s;
    }

    static Out run(Measure m, Progress prog) throws Exception {
        return run(m, prog, true);
    }

    /** allowPhoneSpeaker=false refuses to measure when the output is the phone's speaker or earpiece. */
    static Out run(Measure m, Progress prog, boolean allowPhoneSpeaker) throws Exception {
        Out out = new Out();
        prog.on(ADJUSTING_LEVEL, 0.05f);
        // 1) signal level: ladder of pilots with 1 repetition
        double amp = Double.NaN;
        for (int i = 0; i < LADDER_DB.length; i++) {
            Meas p = m.measure(LADDER_DB[i], 1, 0, 0);
            if (out.outDev.isEmpty()) out.outDev = p.outDev;
            if (!allowPhoneSpeaker && (p.outDev.startsWith("2:") || p.outDev.startsWith("1:"))) {
                out.messages.add(Msg.of("speakerOutput"));
                return out;
            }
            if (p.outDev.startsWith("7:")) { // Bluetooth SCO: call line, mono and low quality
                out.messages.add(Msg.of("bluetoothCallLine"));
                return out;
            }
            double snr = Double.NaN;
            if (p.det.error == null) snr = Math.min(p.det.snrL[0][0], p.det.snrR[0][0]);
            if (snr >= PILOT_MIN_SNR_DB && !p.clipped) {
                amp = Math.min(MAX_AMP_DB, LADDER_DB[i] + 8); // audible: SNR is plenty, but the user must hear it working
                break;
            }
            prog.on(ADJUSTING_LEVEL, 0.05f + 0.05f * (i + 1));
        }
        if (Double.isNaN(amp)) {
            out.messages.add(Msg.of("noSignal"));
            return out;
        }
        out.ampDb = amp;

        // 2) initial measurement
        prog.on(MEASURING, 0.30f);
        Meas m1 = m.measure(amp, REPS, 0, 0);
        if (m1.clipped) {
            amp -= 6;
            out.ampDb = amp;
            out.messages.add(Msg.of("clipped"));
            m1 = m.measure(amp, REPS, 0, 0);
        }
        out.runs.add(m1);
        Sel s1 = pick(m1.det);
        out.sels.add(s1);
        if (!s1.ok) {
            out.messages.add(Msg.because("measurementUnreliable", s1));
            return out;
        }
        double x = clamp(s1.deltaMs);
        if (Math.abs(s1.deltaMs) > MAX_DELAY_MS) out.messages.add(Msg.of("differenceTooLarge"));

        // 3) closed-loop verification (up to 2 passes)
        double bestX = x, bestR = Double.POSITIVE_INFINITY;
        Sel bestSel = s1;
        for (int it = 0; it < 2; it++) {
            prog.on(VERIFYING, 0.55f + 0.2f * it);
            int dL = x > 0 ? (int) Math.round(x * 48) : 0, dR = x < 0 ? (int) Math.round(-x * 48) : 0;
            Meas v = m.measure(amp, REPS, dL, dR);
            out.runs.add(v);
            Sel sv = pick(v.det);
            out.sels.add(sv);
            if (!sv.ok) {
                out.messages.add(Msg.because("verificationUnreliable", sv));
                break;
            }
            double r = sv.deltaMs;
            if (Math.abs(r) < bestR) { bestR = Math.abs(r); bestX = x; bestSel = sv; }
            if (Math.abs(r) <= OK_MS) break;
            x = clamp(x + r);
        }
        if (Double.isInfinite(bestR)) {
            out.messages.add(Msg.of("notVerifiable"));
            return out;
        }
        // L and R practically identical in time and level: mono output, or an already aligned car
        Detector.Result d0 = out.runs.get(0).det;
        double snrDiff = 0;
        int cnt = 0;
        for (int k = 0; k < d0.snrL[0].length; k++) {
            if (d0.ok[0][k]) { snrDiff += Math.abs(d0.snrL[0][k] - d0.snrR[0][k]); cnt++; }
        }
        if (Math.abs(s1.deltaMs) < 0.010 && cnt > 0 && snrDiff / cnt < 0.5) {
            out.messages.add(Msg.of("identicalChannels"));
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
            out.messages.add(Msg.withValue("notConverging", Math.round(bestR * 1000)));
        } else {
            out.messages.add(Msg.withValue("notConvergingRejected", Math.round(bestR * 1000)));
            return out;
        }
        out.apply = true;
        return out;
    }

    private static double clamp(double x) {
        return Math.max(-MAX_DELAY_MS, Math.min(MAX_DELAY_MS, x));
    }
}
