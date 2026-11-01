import '../entities/delay_setting.dart';
import '../entities/guard_status.dart';
import '../entities/measurement.dart';

/// Everything the app asks of the native audio layer.
abstract interface class AudioEngine {
  /// Starts capturing and delaying the music app's audio (asks the user for screen-capture consent).
  Future<void> start(DelaySetting delay);

  /// Changes the delay of a running capture, optionally sliding to it over [rampSeconds].
  Future<void> setDelay(DelaySetting delay, {double? rampSeconds});

  Future<void> stop();

  Future<bool> isActive();

  Future<void> requestPermissions();

  Future<bool> hasMicrophonePermission();

  Future<GuardStatus> guardStatus();

  Future<void> ensureGuard();

  /// Returns a pending notice from the capture service, clearing it.
  Future<CaptureNotice?> takeCaptureNotice();

  Future<void> keepScreenOn(bool on);

  Future<void> playEarcon(Earcon earcon);

  /// Sends a "play" media key, used to resume music the measurement paused.
  Future<void> resumeMedia();

  /// Starts the measurement thread; false when one is already running.
  Future<bool> startMeasurement();

  Future<MeasurementStatus> measurementStatus();
}
