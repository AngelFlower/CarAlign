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

/** Ejecuta el flujo automatico en un hilo y deja estado y resultado para que la interfaz los consulte. */
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
        phase = "Preparando";
        frac = 0;
        new Thread(() -> run(app), "autoalign").start();
        return true;
    }

    /** JSON no admite NaN: las repeticiones no validas se guardan como null. */
    private static Object num(double v) {
        return Double.isNaN(v) || Double.isInfinite(v) ? JSONObject.NULL : (Object) v;
    }

    private static void run(Context app) {
        AudioManager am = app.getSystemService(AudioManager.class);
        AudioFocusRequest fr = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setOnAudioFocusChangeListener(c -> { }).build();
        JSONObject res = new JSONObject();
        String stamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
        File base = SharedDirs.primary(app); // Android/media: el PC puede bajar los informes tambien en Android 11+
        File dir = new File(base, "reportes");
        dir.mkdirs();
        try {
            if (CaptureService.active) { // la captura y la medicion no conviven
                phase = "Deteniendo la captura";
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
            // para pruebas de escritorio: crear files/permitir_altavoz permite medir con el altavoz del telefono
            boolean allowSpeaker = SharedDirs.exists(app, "permitir_altavoz");
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
            res.put("messages", new JSONArray(o.messages));
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
            if (o.runs.isEmpty() && !o.outDev.isEmpty()) res.put("out", o.outDev); // rechazo antes de medir
            if (!o.runs.isEmpty()) {
                res.put("out", o.runs.get(0).outDev);
                res.put("in", o.runs.get(0).inDev);
                res.put("noiseDbfs", o.runs.get(0).noiseDbfs);
            }
        } catch (Throwable t) {
            Log.e(TAG, "autoalign fallo", t);
            try {
                res.put("status", "FAIL");
                res.put("apply", false);
                res.put("messages", new JSONArray().put("Error interno: " + t));
            } catch (Exception ignored) { }
        } finally {
            am.abandonAudioFocusRequest(fr);
            try {
                try (FileWriter w = new FileWriter(new File(dir, stamp + ".json"))) { w.write(res.toString(2)); }
            } catch (Exception e) {
                Log.w(TAG, "no se pudo guardar el reporte: " + e);
            }
            Log.i(TAG, "autoalign resultado " + res);
            resultJson = res.toString();
            phase = "Listo";
            frac = 1;
            running = false;
            done = true;
        }
    }
}
