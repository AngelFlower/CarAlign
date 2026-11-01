import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/profile.dart';
import '../../domain/usecases/run_demo.dart';
import 'alignment_controller.dart';
import 'system_status_controller.dart';

/// Plays a profile in steps (0 ms → profile) so the user can hear the effect.
class DemoController extends ChangeNotifier {
  DemoController({
    required RunDemo run,
    required AlignmentController alignment,
    required SystemStatusController status,
    required this.onNeedsGuard,
  })  : _run = run,
        _alignment = alignment,
        _status = status;

  final RunDemo _run;
  final AlignmentController _alignment;
  final SystemStatusController _status;

  /// Called when the demo can't start because the guard is down.
  final void Function() onNeedsGuard;

  DemoSession? _session;
  bool _disposed = false;

  bool running = false;
  DemoFrame frame = const DemoFrame(0, DemoStage.unaligned);
  int profileIndex = 0;
  double seconds = 12;
  double steps = 6;

  List<Profile> get profiles => _alignment.profiles;

  /// The profile selected in the picker, clamped when the list shrinks.
  int get selectedIndex => profiles.isEmpty ? 0 : profileIndex.clamp(0, profiles.length - 1);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void selectProfile(int index) {
    profileIndex = index;
    _notify();
  }

  void setSeconds(double value) {
    seconds = value;
    _notify();
  }

  void setSteps(double value) {
    steps = value;
    _notify();
  }

  void stop() => _session?.stop();

  Future<void> play({required bool loop}) async {
    if (profiles.isEmpty || running) return;
    if (!_status.guard.alive) {
      onNeedsGuard();
      return;
    }
    final profile = profiles[selectedIndex];
    final session = DemoSession();
    _session = session;
    running = true;
    frame = const DemoFrame(0, DemoStage.unaligned);
    _notify();
    try {
      await for (final f in _run(
        profile.delay,
        session,
        loop: loop,
        seconds: seconds,
        steps: steps.round(),
        engineActive: _status.captureActive,
      )) {
        frame = f;
        _notify();
      }
    } finally {
      running = false;
      _alignment.adopt(profile.delay.copyWith(milliseconds: frame.shownMs));
      await _status.refreshCapture();
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _session?.stop();
    super.dispose();
  }
}
