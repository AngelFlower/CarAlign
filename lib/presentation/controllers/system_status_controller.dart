import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/guard_status.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/audio_engine.dart';

/// Polls the native layer once a second: capture state, guard state, microphone permission and notices.
class SystemStatusController extends ChangeNotifier {
  SystemStatusController(this._engine) {
    _engine.requestPermissions();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  final AudioEngine _engine;
  final _notices = StreamController<CaptureNotice>.broadcast();
  Timer? _timer;
  bool _disposed = false;

  GuardStatus guard = const GuardStatus();
  bool hasMicrophone = true;
  bool captureActive = false;

  Stream<CaptureNotice> get notices => _notices.stream;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    try {
      await _refreshCapture();
      await _refreshGuard();
      final notice = await _engine.takeCaptureNotice();
      if (notice != null && !_disposed) _notices.add(notice);
      final mic = await _engine.hasMicrophonePermission();
      if (mic != hasMicrophone) {
        hasMicrophone = mic;
        _notify();
      }
    } catch (_) {
      // A failed poll is retried on the next tick.
    }
  }

  Future<void> refreshCapture() => _refreshCapture();

  Future<void> _refreshCapture() async {
    final active = await _engine.isActive();
    if (active != captureActive) {
      captureActive = active;
      _notify();
    }
  }

  Future<void> _refreshGuard() async {
    final status = await _engine.guardStatus();
    if (status != guard) {
      guard = status;
      _notify();
    }
  }

  Future<void> requestPermissions() => _engine.requestPermissions();

  Future<void> ensureGuard() => _engine.ensureGuard();

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _notices.close();
    super.dispose();
  }
}
