package dev.angelflower.caralign;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;
import android.os.PowerManager;

import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.Locale;

import dadb.Dadb;

/** Phone compatibility report: shows what the device supports and helps debug other brands without owning them. */
final class Diagnostics {
    private Diagnostics() {}

    static String report(Context c) {
        StringBuilder b = new StringBuilder();
        AudioManager am = c.getSystemService(AudioManager.class);
        PackageManager pm = c.getPackageManager();

        b.append("== Device\n");
        line(b, "Make/model", Build.MANUFACTURER + " " + Build.MODEL + " (" + Build.DEVICE + ")");
        line(b, "Android", Build.VERSION.RELEASE + " (API " + Build.VERSION.SDK_INT + "), patch " + Build.VERSION.SECURITY_PATCH);
        line(b, "Architecture", Build.SUPPORTED_ABIS.length > 0 ? Build.SUPPORTED_ABIS[0] : "?");
        line(b, "CarAlign version", versionName(c));

        b.append("\n== Audio\n");
        line(b, "Native output sample rate", am.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE) + " Hz");
        line(b, "Frames per buffer", am.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER));
        line(b, "Unprocessed source (UNPROCESSED)", "true".equals(am.getProperty(AudioManager.PROPERTY_SUPPORT_AUDIO_SOURCE_UNPROCESSED))
                ? "advertised" : "not advertised (tried anyway; VOICE_RECOGNITION is the fallback)");
        line(b, "Low latency", yes(pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)));
        line(b, "Pro audio", yes(pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)));
        line(b, "Microphone", yes(pm.hasSystemFeature(PackageManager.FEATURE_MICROPHONE)));
        int mics = 0;
        for (AudioDeviceInfo d : am.getDevices(AudioManager.GET_DEVICES_INPUTS)) {
            if (d.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) mics++;
        }
        line(b, "Built-in microphones", String.valueOf(mics));
        StringBuilder outs = new StringBuilder();
        for (AudioDeviceInfo d : am.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
            outs.append(d.getType()).append(':').append(d.getProductName()).append("  ");
        }
        line(b, "Outputs (type:name)", outs.toString().trim());

        b.append("\n== Sensors and permissions\n");
        line(b, "Gyroscope", yes(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_GYROSCOPE)));
        line(b, "Accelerometer", yes(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_ACCELEROMETER)));
        line(b, "Microphone permission", yes(c.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED));
        if (Build.VERSION.SDK_INT >= 33) {
            line(b, "Notifications permission", yes(c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED));
        }
        PowerManager pw = c.getSystemService(PowerManager.class);
        line(b, "Exempt from battery optimization", yes(pw.isIgnoringBatteryOptimizations(c.getPackageName()))
                + " (if not, some manufacturers kill the capture in the background)");

        b.append("\n== Channel for muting the music app\n");
        line(b, "Network ADB (port 5555)", reachable() ? "reachable" : "NOT reachable (`adb tcpip 5555` is needed after every reboot)");
        line(b, "Shizuku", ShizukuChannel.available() ? ("running, " + (ShizukuChannel.permitted() ? "authorized" : "not authorized")) : "not available");
        line(b, "Guard", GuardManager.alive(c) ? "active" : "off (" + GuardManager.state + (GuardManager.detail.isEmpty() ? "" : ": " + GuardManager.detail) + ")");
        return b.toString();
    }

    /** Mutes and restores the app's own audio through the privileged channel: checks that `appops` works on this brand. */
    static String testMute(Context c) {
        Dadb d = null;
        try {
            d = Priv.connect(c);
            String pkg = c.getPackageName();
            d.shell("appops set " + pkg + " PLAY_AUDIO deny");
            String during = d.shell("appops get " + pkg + " PLAY_AUDIO").getOutput().trim();
            d.shell("appops set " + pkg + " PLAY_AUDIO allow");
            String after = d.shell("appops get " + pkg + " PLAY_AUDIO").getOutput().trim();
            boolean ok = during.contains("deny") && after.contains("allow");
            return (ok ? "OK: " : "FAIL: ") + "during=[" + during + "] after=[" + after + "]";
        } catch (Throwable t) {
            return "FAIL using the privileged channel: " + t.getMessage();
        } finally {
            if (d != null) {
                try { d.close(); } catch (Exception ignored) { }
            }
        }
    }

    private static boolean reachable() {
        try (Socket s = new Socket()) {
            s.connect(new InetSocketAddress("127.0.0.1", Priv.PORT), 600);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private static String versionName(Context c) {
        try {
            return c.getPackageManager().getPackageInfo(c.getPackageName(), 0).versionName;
        } catch (Exception e) {
            return "?";
        }
    }

    private static String yes(boolean v) {
        return v ? "yes" : "no";
    }

    private static void line(StringBuilder b, String k, String v) {
        b.append(String.format(Locale.US, "%s: %s%n", k, v));
    }
}
