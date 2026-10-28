#!/bin/sh
# Uso: herramientas/pruebas_jvm/analiza.sh archivo.wav [repeticiones]
set -e
cd "$(dirname "$0")/../.."
OUT=$(mktemp -d)
S=android/app/src/main/java/dev/personal/caralign
javac -d "$OUT" $S/Fft.java $S/Chirp.java $S/TestSignal.java $S/Detector.java \
  herramientas/pruebas_jvm/dev/personal/caralign/AnalizaWav.java
java -Xmx512m -cp "$OUT" dev.personal.caralign.AnalizaWav "$@"
