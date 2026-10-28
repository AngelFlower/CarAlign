package dev.personal.caralign;

import android.content.Context;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Carpetas donde la app y el vigilante (usuario shell) se pasan archivos. Se usan DOS por compatibilidad:
 * Android/media/<app> (funciona en Android 11+; el usuario shell no puede entrar en Android/data en Android 11)
 * y Android/data/<app>/files (la de siempre). Se escribe en las dos y se lee la mas reciente.
 */
final class SharedDirs {
    private SharedDirs() {}

    static File[] all(Context c) {
        List<File> l = new ArrayList<>();
        File[] media = c.getExternalMediaDirs();
        if (media != null && media.length > 0 && media[0] != null) l.add(media[0]);
        File d = c.getExternalFilesDir(null);
        if (d != null) l.add(d);
        for (File f : l) f.mkdirs();
        return l.toArray(new File[0]);
    }

    /** Carpeta preferida para datos que el usuario baja por ADB (informes): Android/media si existe. */
    static File primary(Context c) {
        File[] a = all(c);
        return a.length > 0 ? a[0] : c.getFilesDir();
    }

    static void touch(Context c, String name) {
        long now = System.currentTimeMillis();
        for (File d : all(c)) {
            File f = new File(d, name);
            try {
                if (!f.exists()) f.createNewFile();
                f.setLastModified(now);
            } catch (IOException ignored) {
            }
        }
    }

    static void delete(Context c, String name) {
        for (File d : all(c)) new File(d, name).delete();
    }

    static boolean exists(Context c, String name) {
        for (File d : all(c)) if (new File(d, name).exists()) return true;
        return false;
    }

    /** Edad en ms del archivo mas reciente entre las carpetas; Long.MAX_VALUE si no existe en ninguna. */
    static long ageMs(Context c, String name) {
        long best = Long.MAX_VALUE;
        long now = System.currentTimeMillis();
        for (File d : all(c)) {
            File f = new File(d, name);
            if (f.exists()) best = Math.min(best, now - f.lastModified());
        }
        return best;
    }

    /** Contenido (texto) del archivo mas reciente si tiene menos de maxAgeMs; null si no hay uno fresco. */
    static String readFresh(Context c, String name, long maxAgeMs) {
        File best = null;
        long now = System.currentTimeMillis();
        for (File d : all(c)) {
            File f = new File(d, name);
            if (f.exists() && now - f.lastModified() < maxAgeMs && (best == null || f.lastModified() > best.lastModified())) best = f;
        }
        if (best == null) return null;
        try {
            return new String(java.nio.file.Files.readAllBytes(best.toPath())).trim();
        } catch (Exception e) {
            return null;
        }
    }
}
