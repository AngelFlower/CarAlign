package dev.angelflower.caralign;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.database.Cursor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Reads the title, artist and duration of audio files the user picked, and keeps access to them. */
final class AudioFiles {
    private AudioFiles() {}

    static List<Map<String, Object>> describe(Context ctx, List<Uri> uris) {
        List<Map<String, Object>> out = new ArrayList<>();
        ContentResolver cr = ctx.getContentResolver();
        for (Uri uri : uris) {
            try {
                cr.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } catch (Exception ignored) { } // some providers don't offer persistable grants
            String title = null, artist = null;
            long durationMs = 0;
            MediaMetadataRetriever r = new MediaMetadataRetriever();
            try {
                r.setDataSource(ctx, uri);
                title = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
                artist = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
                String d = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
                if (d != null) durationMs = Long.parseLong(d);
            } catch (Exception ignored) {
            } finally {
                try { r.release(); } catch (Exception ignored) { }
            }
            if (title == null || title.trim().isEmpty()) title = displayName(cr, uri);
            Map<String, Object> m = new HashMap<>();
            m.put("uri", uri.toString());
            m.put("title", title);
            m.put("artist", artist == null ? "" : artist);
            m.put("durationMs", durationMs);
            out.add(m);
        }
        return out;
    }

    private static String displayName(ContentResolver cr, Uri uri) {
        try (Cursor c = cr.query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null)) {
            if (c != null && c.moveToFirst()) {
                String n = c.getString(0);
                int dot = n.lastIndexOf('.');
                return dot > 0 ? n.substring(0, dot) : n;
            }
        } catch (Exception ignored) { }
        String last = uri.getLastPathSegment();
        return last == null ? "?" : last;
    }
}
