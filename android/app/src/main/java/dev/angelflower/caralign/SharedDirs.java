package dev.angelflower.caralign;

import android.content.Context;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Folders where the app and the guard (shell user) exchange files. TWO are used for compatibility:
 * Android/media/<app> (works on Android 11+; the shell user cannot enter Android/data on Android 11)
 * and Android/data/<app>/files (the traditional one). Writes go to both and reads take the newest.
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

    /** Preferred folder for data the user pulls over ADB (reports): Android/media when it exists. */
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

    /** Age in ms of the newest file across the folders; Long.MAX_VALUE if it exists in none. */
    static long ageMs(Context c, String name) {
        long best = Long.MAX_VALUE;
        long now = System.currentTimeMillis();
        for (File d : all(c)) {
            File f = new File(d, name);
            if (f.exists()) best = Math.min(best, now - f.lastModified());
        }
        return best;
    }

    /** Text content of the newest file if it is younger than maxAgeMs; null if none is fresh. */
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
