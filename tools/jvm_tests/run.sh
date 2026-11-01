#!/bin/sh
# Compiles the pure processing core and runs the simulations (no Android, no phone).
set -e
cd "$(dirname "$0")/../.."
OUT=$(mktemp -d)
S=android/app/src/main/java/dev/angelflower/caralign
T=tools/jvm_tests/dev/angelflower/caralign
javac -d "$OUT" $S/Fft.java $S/Chirp.java $S/TestSignal.java $S/Detector.java $S/AlignLogic.java $S/DelayLine.java \
  $T/SimTest.java $T/DelayTest.java $T/LongRunTest.java
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.DelayTest
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.LongRunTest
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.SimTest
