#!/bin/sh
# Compila el nucleo puro de procesado y corre las simulaciones (sin Android ni telefono).
set -e
cd "$(dirname "$0")/../.."
OUT=$(mktemp -d)
S=android/app/src/main/java/dev/angelflower/caralign
javac -d "$OUT" $S/Fft.java $S/Chirp.java $S/TestSignal.java $S/Detector.java $S/AlignLogic.java $S/DelayLine.java \
  herramientas/pruebas_jvm/dev/angelflower/caralign/SimTest.java herramientas/pruebas_jvm/dev/angelflower/caralign/DelayTest.java herramientas/pruebas_jvm/dev/angelflower/caralign/LongRunTest.java
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.DelayTest
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.LongRunTest
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.SimTest
