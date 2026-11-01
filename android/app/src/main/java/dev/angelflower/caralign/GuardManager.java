package dev.angelflower.caralign;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import dadb.Dadb;

/** Starts the playback guard when the app opens and keeps its liveness contract (app_alive). */
final class GuardManager {
    private static final String TAG = "CarAlign";
    static final String REMOTE = "/data/local/tmp/caralign_guard.sh";

    /** state: idle, auth, shizuku, starting, alive, error. detail: `code` or `code:argument` (localized by Flutter). */
    static volatile String state = "idle", detail = "";
    private static boolean busy;
    private static Thread lease;

    private GuardManager() {}

    static boolean alive(Context c) {
        return SharedDirs.ageMs(c, "guard_alive") < 5000;
    }

    /** Renews app_alive every second while the activity is visible. */
    static synchronized void startLease(Context c) {
        if (lease != null) return;
        final Context app = c.getApplicationContext();
        lease = new Thread(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    SharedDirs.touch(app, "app_alive");
                    Thread.sleep(1000);
                }
            } catch (InterruptedException ignored) {
            } catch (Exception e) {
                Log.w(TAG, "app_alive: " + e);
            }
        }, "lease");
        lease.start();
    }

    static synchronized void stopLease() {
        if (lease != null) lease.interrupt();
        lease = null;
    }

    static synchronized void ensure(Context app) {
        if (busy || alive(app)) {
            if (alive(app)) { state = "alive"; detail = ""; }
            return;
        }
        busy = true;
        state = "auth";
        detail = "";
        new Thread(() -> {
            try {
                start(app);
            } finally {
                synchronized (GuardManager.class) { busy = false; }
            }
        }, "guard-start").start();
    }

    private static byte[] script(Context app) throws Exception {
        try (InputStream in = app.getAssets().open("caralign_guard.sh")) {
            java.io.ByteArrayOutputStream b = new java.io.ByteArrayOutputStream();
            byte[] buf = new byte[4096];
            int n;
            while ((n = in.read(buf)) > 0) b.write(buf, 0, n);
            return b.toByteArray();
        }
    }

    private static void waitAlive(Context app) throws InterruptedException {
        for (int i = 0; i < 20 && !alive(app); i++) Thread.sleep(250);
    }

    private static void start(Context app) {
        String adbErr;
        try {
            startViaAdb(app);
            finish(app);
            return;
        } catch (Throwable t) {
            Log.w(TAG, "guard via ADB: " + t);
            String m = String.valueOf(t.getMessage());
            adbErr = m.contains("Connection refused") || m.contains("ECONNREFUSED") || m.contains("Failed to connect")
                    ? "adbInactiveNoShizuku" : "adbFailedNoShizuku:" + m;
        }
        // plan B: Shizuku (can start on its own when the phone boots, no computer needed)
        if (ShizukuChannel.available()) {
            try {
                startViaShizuku(app);
                finish(app);
                return;
            } catch (Throwable t) {
                Log.w(TAG, "guard via Shizuku: " + t);
                state = "error";
                detail = "shizukuFailed:" + t.getMessage();
                return;
            }
        }
        state = "error";
        detail = adbErr;
    }

    private static void finish(Context app) {
        if (alive(app)) {
            state = "alive";
            detail = "";
        } else {
            state = "error";
            detail = "notStarted";
        }
    }

    private static void startViaAdb(Context app) throws Exception {
        Dadb d = null;
        try {
            d = Priv.connect(app);
            d.shell("id -u"); // forces authentication (the phone shows its prompt if needed)
            state = "starting";
            File tmp = new File(app.getCacheDir(), "tidal_guard.sh");
            try (FileOutputStream out = new FileOutputStream(tmp)) { out.write(script(app)); }
            d.push(tmp, REMOTE, 493, System.currentTimeMillis());
            d.shell("pkill -f '[c]aralign_guard.sh'"); // old instances (the pattern doesn't match itself)
            Thread.sleep(500);
            d.shell("setsid nohup sh " + REMOTE + " </dev/null >/dev/null 2>&1 &");
            waitAlive(app);
        } finally {
            if (d != null) {
                try { d.close(); } catch (Exception ignored) { }
            }
        }
    }

    private static void startViaShizuku(Context app) throws Exception {
        if (!ShizukuChannel.permitted()) {
            state = "shizuku"; // the UI asks the user to authorize CarAlign in the Shizuku prompt
            if (!ShizukuChannel.requestAndWait()) throw new IllegalStateException("CarAlign was not authorized in Shizuku");
        }
        state = "starting";
        ShizukuChannel.run("cat > " + REMOTE + " && chmod 755 " + REMOTE, script(app));
        ShizukuChannel.run("pkill -f '[c]aralign_guard.sh'", null);
        Thread.sleep(500);
        ShizukuChannel.run("setsid nohup sh " + REMOTE + " </dev/null >/dev/null 2>&1 &", null);
        waitAlive(app);
    }
}
