/// Compatibility report and checks for the privileged muting channel.
abstract interface class DiagnosticsRepository {
  Future<String> report();

  /// Mutes and restores the app's own audio through the privileged channel.
  /// The result starts with `OK` on success and `FAIL` otherwise.
  Future<String> testMute();

  /// Opens the system battery-optimization settings.
  Future<void> openBatterySettings();
}
