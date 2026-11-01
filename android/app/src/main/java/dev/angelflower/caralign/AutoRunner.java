package dev.angelflower.caralign;

import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.util.Log;
import android.view.KeyEvent;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/** Runs the automatic flow on a thread and leaves its state and result for the UI to poll. */
final class AutoRunner {
    private static final String TAG = "CarAlign";

    static volatile boolean running, done;
    static volatile String phase = "", resultJson = "";
    static volatile float frac;

    private AutoRunner() {}

    static synchronized boolean start(Context app) {
        if (running) return false;
        running = true;
        done = false;
        resultJson = "";
        phase = AlignLogic.PREPARING;
        frac = 0;
        new Thread(() -> run(app), "autoalign").start();
        return true;
    }

    /** JSON has no NaN: invalid repetitions are stored as null. */
    private static Object num(double v) {
        return Double.isNaN(v) || Double.isInfinite(v) ? JSONObject.NULL : (Object) v;
    }

    private static JSONArray messagesJson(java.util.List<AlignLogic.Msg> messages) throws Exception {
        JSONArray arr = new JSONArray();
        for (AlignLogic.Msg m : messages) {
            JSONObject j = new JSONObject();
            j.put("code", m.code);
            if (m.reason != null) j.put("reason", m.reason);
            if (m.value != 0) j.put("value", num(m.value));
            if (m.text != null) j.put("text", m.text);
            arr.put(j);
        }
        return arr;
    }

    private static void run(Context app) {
        AudioManager am = app.getSystemService(AudioManager.class);
        AudioFocusRequest fr = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setOnAudioFocusChangeListener(c -> { }).build();
        JSONObject res = new JSONObject();
        String stamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
        File base = SharedDirs.primary(app); // Android/media: a computer can pull the reports on Android 11+ too
        File dir = new File(base, "reports");
        dir.mkdirs();
        try {
            if (CaptureService.active) { // capture and measurement cannot coexist
                phase = AlignLogic.STOPPING_CAPTURE;
                app.stopService(new Intent(app, CaptureService.class));
                Thread.sleep(1800);
            }
            boolean wasPlaying = am.isMusicActive();
            res.put("wasPlaying", wasPlaying);
            am.requestAudioFocus(fr);
            am.dispatchMediaKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PAUSE));
            am.dispatchMediaKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PAUSE));
            Thread.sleep(600);

            Measurer m = new Measurer(app, dir, stamp);
            // for desktop tests: creating files/allow_speaker permits measuring through the phone speaker
            boolean allowSpeaker = SharedDirs.exists(app, "allow_speaker");
            AlignLogic.Out o = AlignLogic.run(m, (ph, f) -> { phase = ph; frac = f; }, allowSpeaker);
            res.put("status", o.status);
            res.put("apply", o.apply);
            res.put("delayLeftMs", o.delayLeftMs());
            res.put("delayRightMs", o.delayRightMs());
            res.put("xMs", o.xMs);
            res.put("residualUs", num(o.residualMs * 1000));
            res.put("sigmaUs", num(o.sigmaMs * 1000));
            res.put("valid", o.valid);
            res.put("band", o.band);
            res.put("ampDb", o.ampDb);
            res.put("reps", AlignLogic.REPS);
            res.put("messages", messagesJson(o.messages));
            JSONArray runs = new JSONArray();
            for (AlignLogic.Meas r : o.runs) {
                JSONObject j = new JSONObject();
                j.put("ampDb", r.ampDb);
                j.put("noiseDbfs", num(r.noiseDbfs));
                j.put("peak", r.peak);
                j.put("clipped", r.clipped);
                j.put("out", r.outDev);
                j.put("in", r.inDev);
                j.put("maxRot", r.maxRot);
                j.put("maxAcc", r.maxAcc);
                j.put("motionDiscarded", r.motionDiscarded);
                j.put("file", r.file);
                if (r.det != null && r.det.error == null) {
                    j.put("driftPpm", r.det.driftPpm);
                    JSONObject bands = new JSONObject();
                    for (int b = 0; b < Detector.NB; b++) {
                        JSONObject bj = new JSONObject();
                        bj.put("medianMs", num(r.det.medianMs[b]));
                        bj.put("sigmaMs", num(r.det.sigmaMs[b]));
                        bj.put("valid", r.det.valid[b]);
                        JSONArray ds = new JSONArray();
                        for (double d : r.det.deltaMs[b]) ds.put(num(d));
                        bj.put("deltas", ds);
                        bands.put(Detector.BAND_NAMES[b], bj);
                    }
                    j.put("bands", bands);
                } else if (r.det != null) {
                    j.put("error", r.det.error);
                }
                runs.put(j);
            }
            res.put("runs", runs);
            if (!o.runs.isEmpty() && o.runs.get(0).det != null && o.runs.get(0).det.error == null) {
                JSONObject bm = new JSONObject();
                for (int b = 0; b < Detector.NB; b++) bm.put(Detector.BAND_NAMES[b], num(o.runs.get(0).det.medianMs[b]));
                res.put("bandsMs", bm);
            }
            if (o.runs.isEmpty() && !o.outDev.isEmpty()) res.put("out", o.outDev); // rejected before measuring
            if (!o.runs.isEmpty()) {
                res.put("out", o.runs.get(0).outDev);
                res.put("in", o.runs.get(0).inDev);
                res.put("noiseDbfs", o.runs.get(0).noiseDbfs);
            }
        } catch (Throwable t) {
            Log.e(TAG, "autoalign failed", t);
            try {
                res.put("status", "FAIL");
                res.put("apply", false);
                res.put("messages", messagesJson(java.util.Collections.singletonList(
                        AlignLogic.Msg.text("internalError", String.valueOf(t)))));
            } catch (Exception ignored) { }
        } finally {
            am.abandonAudioFocusRequest(fr);
            try {
                try (FileWriter w = new FileWriter(new File(dir, stamp + ".json"))) { w.write(res.toString(2)); }
            } catch (Exception e) {
                Log.w(TAG, "could not save the report: " + e);
            }
            Log.i(TAG, "autoalign result " + res);
            resultJson = res.toString();
            phase = AlignLogic.DONE;
            frac = 1;
            running = false;
            done = true;
        }
    }
}
