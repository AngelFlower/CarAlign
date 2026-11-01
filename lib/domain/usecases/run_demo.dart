import '../entities/delay_setting.dart';
import '../repositories/audio_engine.dart';
import '../repositories/local_player.dart';

enum DemoStage { unaligned, centering, aligned, removing }

/// One visible state of the demo.
class DemoFrame {
  const DemoFrame(this.shownMs, this.stage, {this.step = 0, this.totalSteps = 0});

  final double shownMs;
  final DemoStage stage;

  /// 1-based step inside a ramp; 0 while holding.
  final int step;
  final int totalSteps;
}

/// Lets the caller stop a running demo.
class DemoSession {
  bool _stopped = false;

  bool get stopped => _stopped;

  void stop() => _stopped = true;
}

/// Steps the delay from 0 ms to a profile (and back when `loop` is set) while music plays, either in the
/// built-in player or, with [viaCapture], in the capture of another app.
class RunDemo {
  RunDemo(this._engine, this._player);

  final AudioEngine _engine;
  final LocalPlayer _player;

  /// Emits a frame at each change. The last frame holds the value where the demo stopped.
  Stream<DemoFrame> call(
    DelaySetting target,
    DemoSession session, {
    required bool loop,
    required double seconds,
    required int steps,
    required bool viaCapture,
    required bool engineActive,
  }) async* {
    double shown = 0;
    Future<void> applyDelay(DelaySetting d, {double? rampSeconds}) => viaCapture
        ? _engine.setDelay(d, rampSeconds: rampSeconds)
        : _player.setPlayerDelay(d, rampSeconds: rampSeconds);
    await _engine.keepScreenOn(true);
    try {
      final side = target.side;
      if (viaCapture && !engineActive) {
        await _engine.start(DelaySetting(0, side));
        await Future<void>.delayed(const Duration(seconds: 4)); // the guard needs ~1 s to mute the original
      } else {
        await applyDelay(DelaySetting(0, side), rampSeconds: 0.5);
        if (!viaCapture && !(await _player.snapshot()).playing) await _player.togglePlay();
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
      yield const DemoFrame(0, DemoStage.unaligned);

      Stream<DemoFrame> hold(double ms, DemoStage stage, int holdMs) async* {
        shown = ms;
        yield DemoFrame(ms, stage);
        for (var t = 0; t < holdMs && !session.stopped; t += 100) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      Stream<DemoFrame> rampTo(double to, DemoStage stage) async* {
        final from = shown;
        final span = target.milliseconds <= 0 ? 1.0 : (to - from).abs() / target.milliseconds;
        final secs = (seconds * span).clamp(0.5, 120.0);
        final n = steps.clamp(2, 20);
        final holdMs = (secs * 1000 / n).round();
        for (var k = 1; k <= n && !session.stopped; k++) {
          shown = from + (to - from) * k / n;
          yield DemoFrame(shown, stage, step: k, totalSteps: n);
          await applyDelay(DelaySetting(shown, side), rampSeconds: 0.15);
          for (var t = 0; t < holdMs && !session.stopped; t += 100) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      do {
        yield* hold(0, DemoStage.unaligned, 3500);
        if (session.stopped) break;
        yield* rampTo(target.milliseconds, DemoStage.centering);
        if (session.stopped) break;
        yield* hold(target.milliseconds, DemoStage.aligned, 4000);
        if (loop && !session.stopped) yield* rampTo(0, DemoStage.removing);
      } while (loop && !session.stopped);
    } finally {
      // Freeze where it stopped so the setting matches what is being heard.
      try {
        await applyDelay(DelaySetting(shown, target.side));
      } catch (_) {}
      await _engine.keepScreenOn(false);
    }
  }
}
