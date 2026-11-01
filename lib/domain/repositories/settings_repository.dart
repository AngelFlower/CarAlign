import '../entities/delay_setting.dart';

/// The last delay setting and UI preferences.
abstract interface class SettingsRepository {
  /// Null when the user has never set a delay.
  Future<DelaySetting?> loadDelay();

  Future<void> saveDelay(DelaySetting delay);

  Future<bool> loadHidePlacementGuide();

  Future<void> saveHidePlacementGuide(bool hide);
}
