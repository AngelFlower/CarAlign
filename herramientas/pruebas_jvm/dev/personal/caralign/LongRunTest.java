package dev.personal.caralign;

/**
 * Prueba de larga duracion del retraso: simula minutos de audio a 48 kHz y comprueba que la salida sigue siendo
 * la entrada retrasada exactamente N muestras (un seno de 5 kHz hace visible cualquier oscilacion del retraso).
 */
public class LongRunTest {
    static int in(long n) {
        return (int) Math.round(10000 * Math.sin(2 * Math.PI * 5000.0 * (n % 48000) / 48000.0));
    }

    public static void main(String[] a) {
        int delay = 46, block = 960;
        DelayLine dl = new DelayLine(delay, true);
        short[] buf = new short[block * 2];
        long frame = 0;
        long[] checkMin = {1, 4, 6, 8, 10, 15, 20, 30, 45, 60};
        int ci = 0;
        boolean ok = true;
        long t0 = System.nanoTime();
        while (ci < checkMin.length) {
            for (int i = 0; i < block; i++) {
                buf[2 * i] = (short) in(frame + i);
                buf[2 * i + 1] = (short) in(frame + i);
            }
            dl.process(buf, buf.length);
            if (frame >= checkMin[ci] * 60L * 48000L) { // revisar un bloque en cada hito de minutos
                int bad = 0;
                double maxErr = 0;
                for (int i = 0; i < block; i++) {
                    int expL = (frame + i) < delay ? 0 : in(frame + i - delay);
                    int errL = Math.abs(buf[2 * i] - expL);
                    maxErr = Math.max(maxErr, errL);
                    if (errL > 1) bad++;
                    if (buf[2 * i + 1] != in(frame + i)) bad += 1000; // el canal no retrasado debe quedar intacto
                }
                System.out.printf("%3d min: muestras erroneas %4d/%d, error maximo %.0f  %s%n", checkMin[ci], bad, block, maxErr,
                        bad == 0 ? "OK" : "FALLA");
                if (bad > 0) ok = false;
                ci++;
            }
            frame += block;
        }
        System.out.printf("%.1f s de calculo para %d minutos de audio%n", (System.nanoTime() - t0) / 1e9, checkMin[checkMin.length - 1]);
        if (!ok) System.exit(1);
    }
}
