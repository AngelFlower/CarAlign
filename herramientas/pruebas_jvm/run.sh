#!/bin/sh
# Compila el nucleo puro de procesado y corre las simulaciones (sin Android ni telefono).
set -e
cd "$(dirname "$0")/../.."
OUT=$(mktemp -d)
S=android/app/src/main/java/dev/personal/caralign
javac -d "$OUT" $S/Fft.java $S/Chirp.java $S/TestSignal.java $S/Detector.java $S/AlignLogic.java $S/DelayLine.java \
  herramientas/pruebas_jvm/dev/personal/caralign/SimTest.java herramientas/pruebas_jvm/dev/personal/caralign/DelayTest.java herramientas/pruebas_jvm/dev/personal/caralign/LongRunTest.java
java -Xmx512m -cp "$OUT" dev.personal.caralign.DelayTest
java -Xmx512m -cp "$OUT" dev.personal.caralign.LongRunTest
java -Xmx512m -cp "$OUT" dev.personal.caralign.SimTest
