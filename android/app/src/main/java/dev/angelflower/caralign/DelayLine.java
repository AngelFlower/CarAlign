package dev.angelflower.caralign;

/**
 * Delay of one channel of an interleaved stereo stream, adjustable live without clicks: the delay slides
 * toward its target (linear interpolation between samples) and, at rest, is a whole number of samples.
 * Switching channel goes through a delay of 0 first.
 */
public class DelayLine {
    public static final int MAX_SAMPLES = 1920; // 10 ms at 192 kHz (the capture path never goes above 480)
    static final float DEFAULT_RATE = 0.05f;   // delay samples per audio sample (1 ms over 20 ms)

    private static final int SIZE = 4096, MASK = SIZE - 1;

    private static final class Cmd {
        final int channel, samples;
        final float rate;
        Cmd(int channel, int samples, float rate) { this.channel = channel; this.samples = samples; this.rate = rate; }
    }

    private final float[] ring = new float[SIZE];
    private int write, ch;
    private float cur, tgt, rate = DEFAULT_RATE;
    private Cmd applied, afterSwitch;
    private volatile Cmd pending;

    public DelayLine(int delaySamples, boolean delayLeft) {
        ch = delayLeft ? 0 : 1;
        cur = tgt = clamp(delaySamples);
        pending = applied = new Cmd(ch, (int) cur, DEFAULT_RATE);
    }

    private static int clamp(int s) {
        return Math.max(0, Math.min(MAX_SAMPLES, s));
    }

    /** Normal adjustment: slides to the value at the default rate. */
    public void set(boolean delayLeft, int samples) {
        pending = new Cmd(delayLeft ? 0 : 1, clamp(samples), DEFAULT_RATE);
    }

    /** Linear ramp to `samples` over `seconds` seconds (demo), for a stream at 48 kHz. */
    public void ramp(boolean delayLeft, int samples, double seconds) {
        ramp(delayLeft, samples, seconds, 48000);
    }

    /** Linear ramp to `samples` over `seconds` seconds for a stream at `sampleRate` Hz. */
    public void ramp(boolean delayLeft, int samples, double seconds, int sampleRate) {
        float r = (float) Math.max(1e-6, Math.abs(clamp(samples) - cur) / Math.max(seconds, 0.01) / sampleRate);
        pending = new Cmd(delayLeft ? 0 : 1, clamp(samples), Math.min(r, 1f));
    }

    public void setDelay(int samples) { // kept for backward compatibility
        set(ch == 0, samples);
    }

    public void setDelayLeft(boolean left) {
        set(left, (int) tgt);
    }

    /** Current delay in samples (informational only; written by the audio thread). */
    public float current() { return cur; }

    /** Delays the chosen channel of buf (L,R,L,R...) in place. */
    public void process(short[] buf, int len) {
        Cmd c = pending;
        if (c != applied) {
            applied = c;
            if (c.channel != ch && (cur > 0 || tgt > 0)) { // go through 0 before switching channel
                afterSwitch = c;
                tgt = 0;
                rate = DEFAULT_RATE * 4;
            } else {
                if (c.channel != ch) switchTo(c.channel);
                tgt = c.samples;
                rate = c.rate;
                afterSwitch = null;
            }
        }
        for (int i = 0; i + 1 < len; i += 2) {
            ring[write] = buf[i + ch];
            if (cur != tgt) {
                float diff = tgt - cur;
                cur = Math.abs(diff) <= rate ? tgt : cur + Math.copySign(rate, diff);
                if (cur == 0 && afterSwitch != null) {
                    switchTo(afterSwitch.channel);
                    tgt = afterSwitch.samples;
                    rate = afterSwitch.rate;
                    afterSwitch = null;
                    ring[write] = buf[i + ch];
                }
            }
            // INTEGER arithmetic for the index: a float only holds exact integers up to 2^24 (5.8 min at 48 kHz) and
            // beyond that the delay jittered sample to sample (a high-pitched screech). Only the fraction is a float.
            int k = (int) cur;
            float fr = cur - k;
            int idx = (write - k) & MASK;
            float y = fr == 0 ? ring[idx] : ring[idx] * (1 - fr) + ring[(idx - 1) & MASK] * fr;
            buf[i + ch] = (short) Math.max(-32768, Math.min(32767, Math.round(y)));
            write = (write + 1) & MASK;
        }
    }

    private void switchTo(int channel) {
        ch = channel;
        java.util.Arrays.fill(ring, 0f);
    }
}
