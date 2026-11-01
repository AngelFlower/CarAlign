package dev.angelflower.caralign;

/**
 * The delay the built-in player applies, shared between the UI thread (which sets it) and the audio thread
 * (which reads it in {@link DelayAudioProcessor}).
 */
final class PlayerDelay {
    private static volatile Setting current = new Setting(0f, true, 0, 0);

    static final class Setting {
        final float ms;
        final boolean left;
        final double rampSeconds;
        final long version;

        Setting(float ms, boolean left, double rampSeconds, long version) {
            this.ms = ms;
            this.left = left;
            this.rampSeconds = rampSeconds;
            this.version = version;
        }
    }

    private PlayerDelay() {}

    /** Sets the delay; with rampSeconds > 0 it slides there linearly, otherwise at the default rate. */
    static synchronized void set(float ms, boolean left, double rampSeconds) {
        current = new Setting(Math.max(0f, ms), left, rampSeconds, current.version + 1);
    }

    static Setting get() {
        return current;
    }
}
