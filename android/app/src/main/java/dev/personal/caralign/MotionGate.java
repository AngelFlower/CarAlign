package dev.personal.caralign;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

/** Registra giroscopio y acelerometro (~50 Hz) para saber si el telefono se movio durante la medicion. */
final class MotionGate implements SensorEventListener {
    // Umbrales gruesos: solo descartan movimiento claro (a ajustar con datos del coche)
    static final double MAX_ROT = 0.35;   // rad/s
    static final double MAX_ACC = 1.5;    // m/s2 de desviacion respecto a la media

    private final SensorManager sm;
    private long[] tg = new long[2048], ta = new long[2048];
    private float[] wg = new float[2048], aa = new float[2048];
    private int ng, na;
    private double mx, my, mz; // media corriente del acelerometro

    MotionGate(Context c) {
        sm = c.getSystemService(SensorManager.class);
    }

    void start() {
        ng = na = 0;
        mx = my = mz = 0;
        Sensor g = sm.getDefaultSensor(Sensor.TYPE_GYROSCOPE), a = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        if (g != null) sm.registerListener(this, g, SensorManager.SENSOR_DELAY_GAME);
        if (a != null) sm.registerListener(this, a, SensorManager.SENSOR_DELAY_GAME);
    }

    void stop() {
        sm.unregisterListener(this);
    }

    @Override
    public synchronized void onSensorChanged(SensorEvent e) {
        if (e.sensor.getType() == Sensor.TYPE_GYROSCOPE) {
            if (ng == tg.length) { tg = grow(tg); wg = grow(wg); }
            tg[ng] = e.timestamp;
            wg[ng++] = (float) Math.sqrt(e.values[0] * e.values[0] + e.values[1] * e.values[1] + e.values[2] * e.values[2]);
        } else {
            double k = na == 0 ? 1 : 0.02;
            mx += k * (e.values[0] - mx); my += k * (e.values[1] - my); mz += k * (e.values[2] - mz);
            double dx = e.values[0] - mx, dy = e.values[1] - my, dz = e.values[2] - mz;
            if (na == ta.length) { ta = grow(ta); aa = grow(aa); }
            ta[na] = e.timestamp;
            aa[na++] = (float) Math.sqrt(dx * dx + dy * dy + dz * dz);
        }
    }

    @Override public void onAccuracyChanged(Sensor s, int a) {}

    /** {maxima rotacion rad/s, maxima desviacion de aceleracion m/s2} entre t0 y t1 (ns, elapsedRealtime). */
    synchronized double[] stats(long t0, long t1) {
        double rot = 0, acc = 0;
        for (int i = 0; i < ng; i++) if (tg[i] >= t0 && tg[i] <= t1) rot = Math.max(rot, wg[i]);
        for (int i = 0; i < na; i++) if (ta[i] >= t0 && ta[i] <= t1) acc = Math.max(acc, aa[i]);
        return new double[]{rot, acc};
    }

    private static long[] grow(long[] x) { return java.util.Arrays.copyOf(x, x.length * 2); }
    private static float[] grow(float[] x) { return java.util.Arrays.copyOf(x, x.length * 2); }
}
