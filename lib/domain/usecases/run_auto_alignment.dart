import '../entities/alignment_result.dart';
import '../entities/measurement.dart';
import '../repositories/audio_engine.dart';

sealed class AutoAlignEvent {
  const AutoAlignEvent();
}

class CountdownTick extends AutoAlignEvent {
  const CountdownTick(this.secondsLeft);

  final int secondsLeft;
}

class MeasurementProgress extends AutoAlignEvent {
  const MeasurementProgress(this.phase, this.fraction);

  final MeasurementPhase phase;
  final double fraction;
}

class MeasurementFinished extends AutoAlignEvent {
  const MeasurementFinished(this.result);

  final AlignmentResult result;
}

/// The native layer refused to start (a measurement was already running).
class MeasurementNotStarted extends AutoAlignEvent {
  const MeasurementNotStarted();
}

/// Countdown with audible cues, then the automatic measurement. Cancel by cancelling the stream subscription.
class RunAutoAlignment {
  RunAutoAlignment(this._engine, {this.tick = const Duration(seconds: 1)});

  static const countdownSeconds = 10;

  final AudioEngine _engine;

  /// Length of one countdown second; shortened in tests.
  final Duration tick;

  Stream<AutoAlignEvent> call() async* {
    await _engine.keepScreenOn(true);
    try {
      var left = countdownSeconds;
      yield CountdownTick(left);
      while (left > 0) {
        await Future<void>.delayed(tick);
        left--;
        yield CountdownTick(left);
        if (left > 0 && left <= 3) _engine.playEarcon(Earcon.tick);
      }
      _engine.playEarcon(Earcon.go);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      yield const MeasurementProgress(MeasurementPhase.preparing, 0);
      if (!await _engine.startMeasurement()) {
        yield const MeasurementNotStarted();
        return;
      }
      MeasurementStatus status;
      do {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        status = await _engine.measurementStatus();
        yield MeasurementProgress(status.phase, status.fraction);
      } while (!status.done);
      final result = status.result!;
      _engine.playEarcon(result.apply ? Earcon.success : Earcon.failure);
      if (!result.apply && result.wasPlaying) {
        await Future<void>.delayed(const Duration(milliseconds: 1200)); // let the failure cue finish
        await _engine.resumeMedia(); // the measurement paused the music; give it back
      }
      yield MeasurementFinished(result);
    } finally {
      await _engine.keepScreenOn(false);
    }
  }
}
