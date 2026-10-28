package dev.personal.caralign;

import android.content.Context;

import java.io.File;

import dadb.AdbKeyPair;
import dadb.Dadb;

/**
 * Canal con privilegios de shell: la app se conecta por loopback al adbd en modo TCP (puerto 5555).
 * Requiere `adb tcpip 5555` tras cada reinicio del telefono y aceptar una vez el aviso de depuracion.
 */
final class Priv {
    static final int PORT = 5555;

    private Priv() {}

    static Dadb connect(Context ctx) throws Exception {
        File priv = new File(ctx.getFilesDir(), "adbkey"), pub = new File(ctx.getFilesDir(), "adbkey.pub");
        if (!priv.exists() || !pub.exists()) AdbKeyPair.generate(priv, pub);
        return Dadb.create("127.0.0.1", PORT, AdbKeyPair.read(priv, pub));
    }
}
