package dev.personal.caralign;

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

/** Informe de compatibilidad del telefono: sirve para saber que soporta y para depurar en otras marcas sin tenerlas. */
final class Diagnostics {
    private Diagnostics() {}

    static String report(Context c) {
        StringBuilder b = new StringBuilder();
        AudioManager am = c.getSystemService(AudioManager.class);
        PackageManager pm = c.getPackageManager();

        b.append("== Dispositivo\n");
        line(b, "Marca/modelo", Build.MANUFACTURER + " " + Build.MODEL + " (" + Build.DEVICE + ")");
        line(b, "Android", Build.VERSION.RELEASE + " (API " + Build.VERSION.SDK_INT + "), parche " + Build.VERSION.SECURITY_PATCH);
        line(b, "Arquitectura", Build.SUPPORTED_ABIS.length > 0 ? Build.SUPPORTED_ABIS[0] : "?");
        line(b, "Versión de CarAlign", versionName(c));

        b.append("\n== Audio\n");
        line(b, "Frecuencia nativa de salida", am.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE) + " Hz");
        line(b, "Fotogramas por buffer", am.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER));
        line(b, "Fuente sin procesar (UNPROCESSED)", "true".equals(am.getProperty(AudioManager.PROPERTY_SUPPORT_AUDIO_SOURCE_UNPROCESSED))
                ? "anunciada" : "no anunciada (se prueba igual; si falla se usa VOICE_RECOGNITION)");
        line(b, "Baja latencia", yes(pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)));
        line(b, "Audio profesional", yes(pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)));
        line(b, "Micrófono", yes(pm.hasSystemFeature(PackageManager.FEATURE_MICROPHONE)));
        int mics = 0;
        for (AudioDeviceInfo d : am.getDevices(AudioManager.GET_DEVICES_INPUTS)) {
            if (d.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) mics++;
        }
        line(b, "Micrófonos integrados", String.valueOf(mics));
        StringBuilder outs = new StringBuilder();
        for (AudioDeviceInfo d : am.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
            outs.append(d.getType()).append(':').append(d.getProductName()).append("  ");
        }
        line(b, "Salidas (tipo:nombre)", outs.toString().trim());

        b.append("\n== Sensores y permisos\n");
        line(b, "Giroscopio", yes(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_GYROSCOPE)));
        line(b, "Acelerómetro", yes(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_ACCELEROMETER)));
        line(b, "Permiso de micrófono", yes(c.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED));
        if (Build.VERSION.SDK_INT >= 33) {
            line(b, "Permiso de notificaciones", yes(c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED));
        }
        PowerManager pw = c.getSystemService(PowerManager.class);
        line(b, "Exenta de ahorro de batería", yes(pw.isIgnoringBatteryOptimizations(c.getPackageName()))
                + " (si no, algunos fabricantes cierran la captura en segundo plano)");

        b.append("\n== Canal para silenciar la app de música\n");
        line(b, "ADB por red (puerto 5555)", reachable() ? "accesible" : "NO accesible (hace falta `adb tcpip 5555` tras cada reinicio)");
        line(b, "Shizuku", ShizukuChannel.available() ? ("en ejecución, " + (ShizukuChannel.permitted() ? "autorizado" : "sin autorizar")) : "no disponible");
        line(b, "Vigilante", GuardManager.alive(c) ? "activo" : "apagado (" + GuardManager.state + (GuardManager.detail.isEmpty() ? "" : ": " + GuardManager.detail) + ")");
        return b.toString();
    }

    /** Silencia y restaura el audio de la propia app por el canal privilegiado: comprueba que `appops` funciona en esta marca. */
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
            return (ok ? "OK: " : "FALLO: ") + "durante=[" + during + "] despues=[" + after + "]";
        } catch (Throwable t) {
            return "FALLO al usar el canal privilegiado: " + t.getMessage();
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
        return v ? "sí" : "no";
    }

    private static void line(StringBuilder b, String k, String v) {
        b.append(String.format(Locale.US, "%s: %s%n", k, v));
    }
}
