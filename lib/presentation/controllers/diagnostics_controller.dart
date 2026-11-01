import 'package:flutter/foundation.dart';

import '../../domain/repositories/diagnostics_repository.dart';

/// State of the diagnostics screen: the device report and the result of the muting test.
class DiagnosticsController extends ChangeNotifier {
  DiagnosticsController(this._repository);

  final DiagnosticsRepository _repository;
  bool _disposed = false;

  /// Null until the first report has loaded.
  String? report;

  /// Null until the muting test has run.
  String? muteResult;
  bool testing = false;

  bool get muteWorks => muteResult?.startsWith('OK') ?? false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadReport() async {
    report = null;
    _notify();
    report = await _repository.report();
    _notify();
  }

  Future<void> testMute() async {
    testing = true;
    muteResult = null;
    _notify();
    muteResult = await _repository.testMute();
    testing = false;
    _notify();
  }

  Future<void> openBatterySettings() => _repository.openBatterySettings();

  /// Plain-text report meant to be pasted into a bug report, so it is always in English.
  String shareableReport() => '${report ?? ''}\n== Mute test\n${muteResult ?? 'not run'}\n';

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
