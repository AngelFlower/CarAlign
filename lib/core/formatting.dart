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
