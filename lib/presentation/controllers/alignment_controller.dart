import 'package:flutter/foundation.dart';

import '../../domain/entities/channel_side.dart';
import '../../domain/entities/delay_setting.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/audio_engine.dart';
import '../../domain/repositories/local_player.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'system_status_controller.dart';

/// Current delay, saved profiles and the capture on/off switch.
class AlignmentController extends ChangeNotifier {
  AlignmentController({
    required AudioEngine engine,
    required LocalPlayer player,
    required ProfileRepository profiles,
    required SettingsRepository settings,
    required SystemStatusController status,
  }) : _engine = engine,
       _player = player,
       _profiles = profiles,
       _settings = settings,
       _status = status {
    _load();
  }

  final AudioEngine _engine;
  final LocalPlayer _player;
  final ProfileRepository _profiles;
  final SettingsRepository _settings;
  final SystemStatusController _status;
  bool _disposed = false;

  DelaySetting delay = const DelaySetting(1.0, ChannelSide.left);

  /// True once a delay has been saved or adjusted, so the home screen can show the status card.
  bool hasDelay = false;
  bool hidePlacementGuide = false;

  /// Advanced mode: capture other music apps instead of using the built-in player.
  bool captureMode = false;
  List<Profile> profiles = [];

  bool get active => _status.captureActive;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _load() async {
    profiles = await _profiles.load();
    final saved = await _settings.loadDelay();
    if (saved != null) {
      delay = saved;
      hasDelay = true;
      await _player.setPlayerDelay(delay);
    }
    captureMode = await _settings.loadCaptureMode();
    hidePlacementGuide = await _settings.loadHidePlacementGuide();
    _notify();
    await _status.refreshCapture();
  }

  Future<void> setHidePlacementGuide(bool hide) async {
    hidePlacementGuide = hide;
    await _settings.saveHidePlacementGuide(hide);
    _notify();
  }

  Future<void> setCaptureMode(bool enabled) async {
    captureMode = enabled;
    await _settings.saveCaptureMode(enabled);
    if (!enabled && active) await _engine.stop();
    _notify();
    await _status.refreshCapture();
  }

  void _commit() {
    hasDelay = true;
    _settings.saveDelay(delay);
    _player.setPlayerDelay(delay);
    if (active) _engine.setDelay(delay);
    _notify();
  }

  void setMilliseconds(double ms) {
    delay = delay.copyWith(milliseconds: DelaySetting.snap(ms));
    _commit();
  }

  void setSide(ChannelSide side) {
    delay = delay.copyWith(side: side);
    _commit();
  }

  Future<void> toggle() async {
    if (active) {
      await _engine.stop();
    } else {
      await _engine.start(delay);
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _status.refreshCapture();
  }

  /// Takes a delay that was measured or demonstrated as the current setting, without touching the capture.
  void adopt(DelaySetting value, {String? saveAs}) {
    delay = value.copyWith(milliseconds: DelaySetting.snap(value.milliseconds));
    hasDelay = true;
    _settings.saveDelay(delay);
    _player.setPlayerDelay(delay);
    if (saveAs != null) profiles.add(Profile(saveAs, delay));
    _profiles.save(profiles);
    _notify();
  }

  void addProfile(String name) {
    profiles.add(Profile(name, delay));
    _profiles.save(profiles);
    _notify();
  }

  void removeProfile(Profile profile) {
    profiles.remove(profile);
    _profiles.save(profiles);
    _notify();
  }

  void loadProfile(Profile profile) {
    delay = profile.delay;
    _commit();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
