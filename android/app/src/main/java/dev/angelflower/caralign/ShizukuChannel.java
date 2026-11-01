package dev.angelflower.caralign;

import android.content.pm.PackageManager;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import rikka.shizuku.Shizuku;

/** Shell channel through Shizuku: an alternative to network ADB, useful after a reboot (Shizuku can start by itself). */
final class ShizukuChannel {
    private static final int REQ = 4242;

    private ShizukuChannel() {}

    static boolean available() {
        try {
            return Shizuku.pingBinder();
        } catch (Throwable t) {
            return false;
        }
    }

    static boolean permitted() {
        try {
            return Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED;
        } catch (Throwable t) {
            return false;
        }
    }

    /** Asks for permission (Shizuku prompt on screen) and waits up to 90 s for it to be granted. */
    static boolean requestAndWait() throws InterruptedException {
        if (permitted()) return true;
        final CountDownLatch latch = new CountDownLatch(1);
        final int[] result = {PackageManager.PERMISSION_DENIED};
        Shizuku.OnRequestPermissionResultListener l = (code, grant) -> {
            if (code == REQ) {
                result[0] = grant;
                latch.countDown();
            }
        };
        Shizuku.addRequestPermissionResultListener(l);
        try {
            Shizuku.requestPermission(REQ);
            latch.await(90, TimeUnit.SECONDS);
        } finally {
            Shizuku.removeRequestPermissionResultListener(l);
        }
        return result[0] == PackageManager.PERMISSION_GRANTED;
    }

    /** Runs `sh -c cmd` as the Shizuku user (shell), with optional stdin; returns the output. */
    static String run(String cmd, byte[] stdin) throws Exception {
        Method m = Shizuku.class.getDeclaredMethod("newProcess", String[].class, String[].class, String.class);
        m.setAccessible(true); // private in API 13
        Process p = (Process) m.invoke(null, new String[]{"sh", "-c", cmd}, null, null);
        if (stdin != null) {
            try (OutputStream o = p.getOutputStream()) { o.write(stdin); }
        } else {
            p.getOutputStream().close();
        }
        String out = read(p.getInputStream());
        p.waitFor();
        return out;
    }

    private static String read(InputStream in) throws Exception {
        ByteArrayOutputStream b = new ByteArrayOutputStream();
        byte[] buf = new byte[2048];
        int n;
        while ((n = in.read(buf)) > 0) b.write(buf, 0, n);
        return b.toString("UTF-8");
    }
}
