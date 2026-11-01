package dev.angelflower.caralign;

import android.content.Context;

import java.io.File;

import dadb.AdbKeyPair;
import dadb.Dadb;

/**
 * Shell-privileged channel: the app connects over loopback to adbd in TCP mode (port 5555).
 * Needs `adb tcpip 5555` after every reboot and accepting the debugging prompt once.
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
