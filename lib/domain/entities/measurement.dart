import 'alignment_result.dart';

enum MeasurementPhase { preparing, adjustingLevel, measuring, verifying, stoppingCapture, done }

/// Snapshot of the native measurement thread.
class MeasurementStatus {
  const MeasurementStatus({required this.phase, required this.fraction, required this.done, this.result});

  final MeasurementPhase phase;
  final double fraction;
  final bool done;
  final AlignmentResult? result;
}

/// Short sounds that tell the user how the measurement is going without looking at the screen.
enum Earcon { tick, go, success, failure }

/// Message raised by the capture service, localized by the presentation layer.
enum CaptureNotice { captureBlocked }
