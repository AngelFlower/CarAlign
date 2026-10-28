package dev.angelflower.caralign;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.view.WindowManager;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import android.media.projection.MediaProjectionManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final int REQ_PROJECTION = 1;

    private float pendingDelayMs;
    private boolean pendingLeft = true;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "caralign")
                .setMethodCallHandler(this::onCall);
    }

    private void onCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "start":
                pendingDelayMs = ((Number) call.argument("delayMs")).floatValue();
                pendingLeft = Boolean.TRUE.equals(call.argument("left"));
                MediaProjectionManager m = getSystemService(MediaProjectionManager.class);
                // En Android 14+ el aviso ofrece capturar "una sola app", que limitaria el audio; se fuerza la pantalla completa
                Intent consent = android.os.Build.VERSION.SDK_INT >= 34
                        ? m.createScreenCaptureIntent(android.media.projection.MediaProjectionConfig.createConfigForDefaultDisplay())
                        : m.createScreenCaptureIntent();
                startActivityForResult(consent, REQ_PROJECTION);
                result.success(null);
                break;
            case "set":
                startService(new Intent(this, CaptureService.class)
                        .putExtra("delay_ms", ((Number) call.argument("delayMs")).floatValue())
                        .putExtra("left", Boolean.TRUE.equals(call.argument("left")))
                        .putExtra("ramp_s", call.argument("seconds") == null ? 0f
                                : ((Number) call.argument("seconds")).floatValue()));
                result.success(null);
                break;
            case "stop":
                stopService(new Intent(this, CaptureService.class));
                result.success(null);
                break;
            case "active":
                result.success(CaptureService.active);
                break;
            case "perms":
                requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.POST_NOTIFICATIONS}, 2);
                result.success(checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED);
                break;
            case "hasMic":
                result.success(checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED);
                break;
            case "autoStart":
                result.success(AutoRunner.start(getApplicationContext()));
                break;
            case "autoStatus": {
                Map<String, Object> st = new HashMap<>();
                st.put("phase", AutoRunner.phase);
                st.put("frac", (double) AutoRunner.frac);
                st.put("running", AutoRunner.running);
                st.put("done", AutoRunner.done);
                st.put("result", AutoRunner.resultJson);
                result.success(st);
                break;
            }
            case "mediaPlay": {
                android.media.AudioManager am = getSystemService(android.media.AudioManager.class);
                am.dispatchMediaKeyEvent(new android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PLAY));
                am.dispatchMediaKeyEvent(new android.view.KeyEvent(android.view.KeyEvent.ACTION_UP, android.view.KeyEvent.KEYCODE_MEDIA_PLAY));
                result.success(null);
                break;
            }
            case "earcon":
                Earcon.play(((Number) call.arguments).intValue());
                result.success(null);
                break;
            case "keepScreenOn": {
                final boolean on = Boolean.TRUE.equals(call.arguments);
                runOnUiThread(() -> {
                    if (on) getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                    else getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                });
                result.success(null);
                break;
            }
            case "diagnostics":
                new Thread(() -> {
                    String r = Diagnostics.report(getApplicationContext());
                    runOnUiThread(() -> result.success(r));
                }).start();
                break;
            case "testMute":
                new Thread(() -> {
                    String r = Diagnostics.testMute(getApplicationContext());
                    runOnUiThread(() -> result.success(r));
                }).start();
                break;
            case "batteryExempt": {
                // Sin el permiso REQUEST_IGNORE_BATTERY_OPTIMIZATIONS (restringido en Google Play): abre la lista de ajustes
                try {
                    startActivity(new Intent(android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS));
                } catch (Exception e) {
                    startActivity(new Intent(android.provider.Settings.ACTION_SETTINGS));
                }
                result.success(null);
                break;
            }
            case "captureNotice": {
                String n = CaptureService.notice;
                CaptureService.notice = "";
                result.success(n);
                break;
            }
            case "guardInfo": {
                Map<String, Object> g = new HashMap<>();
                g.put("alive", GuardManager.alive(this));
                g.put("state", GuardManager.state);
                g.put("detail", GuardManager.detail);
                result.success(g);
                break;
            }
            case "guardEnsure":
                GuardManager.ensure(getApplicationContext());
                result.success(null);
                break;
            case "guardAlive":
                result.success(GuardManager.alive(this));
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        GuardManager.startLease(getApplicationContext()); // mientras la app esta visible, el vigilante sigue vivo
        GuardManager.ensure(getApplicationContext());
    }

    @Override
    protected void onStop() {
        super.onStop();
        GuardManager.stopLease(); // si no hay captura, el vigilante se apaga solo en unos segundos
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        super.onActivityResult(req, res, data);
        if (req == REQ_PROJECTION && res == RESULT_OK) {
            startForegroundService(new Intent(this, CaptureService.class)
                    .putExtra("code", res)
                    .putExtra("data", data)
                    .putExtra("delay_ms", pendingDelayMs)
                    .putExtra("left", pendingLeft));
        }
    }
}
