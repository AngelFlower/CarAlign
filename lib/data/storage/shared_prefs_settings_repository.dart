import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/channel_side.dart';
import '../../domain/entities/delay_setting.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const _delayKey = 'delayMs';
  static const _leftKey = 'left';
  static const _hideGuideKey = 'hideGuide';

  @override
  Future<DelaySetting?> loadDelay() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getDouble(_delayKey);
    if (ms == null) return null;
    final left = prefs.getBool(_leftKey) ?? true;
    return DelaySetting(ms, left ? ChannelSide.left : ChannelSide.right);
  }

  @override
  Future<void> saveDelay(DelaySetting delay) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_delayKey, delay.milliseconds);
    await prefs.setBool(_leftKey, delay.side == ChannelSide.left);
  }

  @override
  Future<bool> loadHidePlacementGuide() async =>
      (await SharedPreferences.getInstance()).getBool(_hideGuideKey) ?? false;

  @override
  Future<void> saveHidePlacementGuide(bool hide) async =>
      (await SharedPreferences.getInstance()).setBool(_hideGuideKey, hide);
}
