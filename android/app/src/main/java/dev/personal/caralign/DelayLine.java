package dev.personal.caralign;

/**
 * Retraso de un canal de un flujo estereo entrelazado, ajustable en vivo y sin chasquidos: el retraso se
 * desliza hacia el objetivo (interpolacion lineal entre muestras) y, en reposo, es un numero entero de
 * muestras. Cambiar de canal se hace pasando antes por retraso 0.
 */
public class DelayLine {
    public static final int MAX_SAMPLES = 480; // 10 ms a 48 kHz
    static final float DEFAULT_RATE = 0.05f;   // muestras de retraso por muestra de audio (1 ms en 20 ms)

    private static final int SIZE = 1024, MASK = SIZE - 1;

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

    /** Ajuste normal: se desliza hacia el valor con la velocidad por defecto. */
    public void set(boolean delayLeft, int samples) {
        pending = new Cmd(delayLeft ? 0 : 1, clamp(samples), DEFAULT_RATE);
    }

    /** Rampa lineal hasta `samples` en `seconds` segundos (demostracion). */
    public void ramp(boolean delayLeft, int samples, double seconds) {
        float r = (float) Math.max(1e-6, Math.abs(clamp(samples) - cur) / Math.max(seconds, 0.01) / 48000.0);
        pending = new Cmd(delayLeft ? 0 : 1, clamp(samples), Math.min(r, 1f));
    }

    public void setDelay(int samples) { // compatibilidad con la version anterior
        set(ch == 0, samples);
    }

    public void setDelayLeft(boolean left) {
        set(left, (int) tgt);
    }

    /** Retraso actual en muestras (solo informativo; lo escribe el hilo de audio). */
    public float current() { return cur; }

    /** Retrasa el canal elegido de buf (L,R,L,R...) in situ. */
    public void process(short[] buf, int len) {
        Cmd c = pending;
        if (c != applied) {
            applied = c;
            if (c.channel != ch && (cur > 0 || tgt > 0)) { // pasar por 0 antes de cambiar de canal
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
            // Aritmetica ENTERA para el indice: un float solo guarda enteros exactos hasta 2^24 (5.8 min a 48 kHz) y
            // despues el retraso oscilaba muestra a muestra (rechinido agudo). Solo la parte fraccionaria es float.
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
