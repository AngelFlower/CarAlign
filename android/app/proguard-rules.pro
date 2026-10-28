# dadb (ADB en loopback) y Shizuku usan reflexión/okio
-keep class dadb.** { *; }
-keep class rikka.shizuku.** { *; }
-keep class moe.shizuku.** { *; }
-dontwarn okio.**
-dontwarn org.slf4j.**
-keep class dev.angelflower.caralign.** { *; }
