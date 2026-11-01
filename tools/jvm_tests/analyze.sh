#!/bin/sh
# Usage: tools/jvm_tests/analyze.sh file.wav [repetitions]
set -e
cd "$(dirname "$0")/../.."
OUT=$(mktemp -d)
S=android/app/src/main/java/dev/angelflower/caralign
javac -d "$OUT" $S/Fft.java $S/Chirp.java $S/TestSignal.java $S/Detector.java \
  tools/jvm_tests/dev/angelflower/caralign/AnalyzeWav.java
java -Xmx512m -cp "$OUT" dev.angelflower.caralign.AnalyzeWav "$@"
