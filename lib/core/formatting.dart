import '../i18n/strings.g.dart';

/// Fixed number of decimals with the locale's separator.
String formatFixed(double value, int digits) => value.toStringAsFixed(digits).replaceAll('.', t.decimalSeparator);

/// Up to [digits] decimals without trailing zeros, using the locale's separator: 1.10 → "1,1".
String formatTrimmed(double value, {int digits = 2}) {
  var s = value.toStringAsFixed(digits);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s.replaceAll('.', t.decimalSeparator);
}

/// Milliseconds as shown in the UI.
String formatMs(double value) => formatTrimmed(value);

/// Playback time as m:ss (or h:mm:ss for long tracks).
String formatDuration(int ms) {
  final total = (ms < 0 ? 0 : ms) ~/ 1000;
  final h = total ~/ 3600, m = (total % 3600) ~/ 60, sec = total % 60;
  final ss = sec.toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}
