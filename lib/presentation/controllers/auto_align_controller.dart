import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/alignment_result.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/usecases/apply_alignment.dart';
import '../../domain/usecases/run_auto_alignment.dart';
import '../../i18n/strings.g.dart';
import 'alignment_controller.dart';
import 'system_status_controller.dart';

enum AutoAlignPhase { idle, countdown, measuring, done }

/// State of the automatic alignment screen: countdown, progress and result.
class AutoAlignController extends ChangeNotifier {
  AutoAlignController({
    required RunAutoAlignment run,
    required ApplyAlignment apply,
    required AlignmentController alignment,
    required SystemStatusController status,
  }) : _run = run,
       _apply = apply,
       _alignment = alignment,
       _status = status;

  final RunAutoAlignment _run;
  final ApplyAlignment _apply;
  final AlignmentController _alignment;
  final SystemStatusController _status;
  StreamSubscription<AutoAlignEvent>? _subscription;
  bool _disposed = false;

  AutoAlignPhase phase = AutoAlignPhase.idle;
  int secondsLeft = 0;
  MeasurementPhase measurementPhase = MeasurementPhase.preparing;
  double fraction = 0;
  AlignmentResult? result;

  bool get busy => phase == AutoAlignPhase.countdown || phase == AutoAlignPhase.measuring;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Runs the countdown, the measurement and, if it succeeded, applies the result.
  Future<void> start() async {
    if (busy) return;
    result = null;
    phase = AutoAlignPhase.countdown;
    secondsLeft = RunAutoAlignment.countdownSeconds;
    _notify();
    final done = Completer<void>();
    _subscription = _run().listen(
      (event) => _onEvent(event),
      onDone: done.complete,
      onError: (_) {
        phase = AutoAlignPhase.idle;
        _notify();
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
  }

  void _onEvent(AutoAlignEvent event) {
    switch (event) {
      case CountdownTick(:final secondsLeft):
        this.secondsLeft = secondsLeft;
      case MeasurementProgress(:final phase, :final fraction):
        this.phase = AutoAlignPhase.measuring;
        measurementPhase = phase;
        this.fraction = fraction;
      case MeasurementNotStarted():
        phase = AutoAlignPhase.idle;
      case MeasurementFinished(:final result):
        phase = AutoAlignPhase.done;
        this.result = result;
        _finish(result);
    }
    _notify();
  }

  Future<void> _finish(AlignmentResult result) async {
    final delay = result.delay;
    if (delay == null) return;
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _alignment.adopt(delay, saveAs: t.home.profiles.autoName(time: time));
    final viaCapture = _alignment.captureMode && _status.guard.alive;
    if (viaCapture || result.wasPlaying) {
      await _apply(result, delay, viaCapture: viaCapture);
      await _status.refreshCapture();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
