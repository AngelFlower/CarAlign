package dev.angelflower.caralign;

import android.content.ComponentName;
import android.content.Context;
import android.net.Uri;

import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.Player;
import androidx.media3.session.MediaController;
import androidx.media3.session.SessionToken;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.MoreExecutors;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controls the built-in player from the activity through a MediaController. Everything here runs on the main
 * thread (the method-channel handler's thread), which is what MediaController requires.
 */
final class LocalPlayerBridge {
    private static MediaController controller;
    private static boolean connecting;
    private static final List<Runnable> waiting = new ArrayList<>();

    private LocalPlayerBridge() {}

    /** Runs `action` as soon as the controller is connected (immediately if it already is). */
    static void whenReady(Context ctx, Runnable action) {
        if (controller != null) {
            action.run();
            return;
        }
        waiting.add(action);
        if (connecting) return;
        connecting = true;
        Context app = ctx.getApplicationContext();
        SessionToken token = new SessionToken(app, new ComponentName(app, PlaybackService.class));
        ListenableFuture<MediaController> future = new MediaController.Builder(app, token).buildAsync();
        future.addListener(() -> {
            connecting = false;
            try {
                controller = future.get();
            } catch (Exception e) {
                waiting.clear();
                return;
            }
            List<Runnable> toRun = new ArrayList<>(waiting);
            waiting.clear();
            for (Runnable r : toRun) r.run();
        }, MoreExecutors.directExecutor());
    }

    static void connect(Context ctx) {
        whenReady(ctx, () -> { });
    }

    private static MediaItem item(Map<String, Object> t) {
        return new MediaItem.Builder()
                .setUri(Uri.parse((String) t.get("uri")))
                .setMediaMetadata(new MediaMetadata.Builder()
                        .setTitle((String) t.get("title"))
                        .setArtist((String) t.get("artist"))
                        .build())
                .build();
    }

    /** Appends tracks (maps with uri, title, artist) to the queue. */
    static void add(Context ctx, List<Map<String, Object>> tracks) {
        whenReady(ctx, () -> {
            List<MediaItem> items = new ArrayList<>();
            for (Map<String, Object> t : tracks) items.add(item(t));
            controller.addMediaItems(items);
            if (controller.getPlaybackState() == Player.STATE_IDLE) controller.prepare();
        });
    }

    /** Replaces the queue without starting playback (used to restore the saved queue). */
    static void restore(Context ctx, List<Map<String, Object>> tracks) {
        whenReady(ctx, () -> {
            if (controller.getMediaItemCount() > 0) return; // the service survived: keep what it has
            List<MediaItem> items = new ArrayList<>();
            for (Map<String, Object> t : tracks) items.add(item(t));
            controller.setMediaItems(items);
            controller.prepare();
        });
    }

    static void remove(Context ctx, int index) {
        whenReady(ctx, () -> {
            if (index >= 0 && index < controller.getMediaItemCount()) controller.removeMediaItem(index);
        });
    }

    static void clear(Context ctx) {
        whenReady(ctx, () -> {
            controller.stop();
            controller.clearMediaItems();
        });
    }

    static void playIndex(Context ctx, int index) {
        whenReady(ctx, () -> {
            if (index < 0 || index >= controller.getMediaItemCount()) return;
            controller.seekTo(index, 0);
            controller.prepare();
            controller.play();
        });
    }

    static void toggle(Context ctx) {
        whenReady(ctx, () -> {
            if (controller.getMediaItemCount() == 0) return;
            if (controller.isPlaying()) {
                controller.pause();
            } else {
                if (controller.getPlaybackState() == Player.STATE_ENDED) controller.seekTo(0, 0);
                controller.prepare();
                controller.play();
            }
        });
    }

    static void next(Context ctx) { whenReady(ctx, () -> controller.seekToNextMediaItem()); }

    static void previous(Context ctx) { whenReady(ctx, () -> controller.seekToPreviousMediaItem()); }

    static void seek(Context ctx, long ms) { whenReady(ctx, () -> controller.seekTo(Math.max(0, ms))); }

    static void pause(Context ctx) {
        whenReady(ctx, () -> controller.pause());
    }

    /** Snapshot for the UI; empty-ish defaults until the controller is connected. */
    static Map<String, Object> state() {
        Map<String, Object> m = new HashMap<>();
        MediaController c = controller;
        if (c == null) {
            m.put("connected", false);
            m.put("playing", false);
            m.put("index", 0);
            m.put("positionMs", 0L);
            m.put("durationMs", 0L);
            m.put("queueSize", 0);
            return m;
        }
        m.put("connected", true);
        m.put("playing", c.isPlaying());
        m.put("index", c.getCurrentMediaItemIndex());
        m.put("positionMs", Math.max(0L, c.getCurrentPosition()));
        m.put("durationMs", Math.max(0L, c.getDuration()));
        m.put("queueSize", c.getMediaItemCount());
        m.put("ended", c.getPlaybackState() == Player.STATE_ENDED);
        return m;
    }
}
