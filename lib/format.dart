/// Formato de milisegundos con coma decimal: 1.10 -> "1,1", 1.08 -> "1,08".
String fmtMs(double v) {
  var s = v.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s.replaceAll('.', ',');
}

/// Origen de audio con nombre amigable a partir del campo `out` del resultado.
class AudioSource {
  const AudioSource(this.name, this.raw, {required this.known});

  /// "Android Auto", "Bluetooth", "Altavoz del teléfono", "USB" o null si no se reconoce.
  final String name;
  final String raw;
  final bool known;

  static AudioSource parse(String? out) {
    final raw = (out ?? '').trim();
    if (raw.isEmpty) return const AudioSource('Origen desconocido', '', known: false);
    final lower = raw.toLowerCase();
    final id = int.tryParse(RegExp(r'^\s*(\d+)').firstMatch(raw)?.group(1) ?? '');
    final isBt = lower.contains('bluetooth') ||
        lower.contains('a2dp') ||
        RegExp(r'(^|[^a-z])bt([^a-z]|$)').hasMatch(lower) ||
        const {7, 8, 26, 27, 30}.contains(id);
    if (lower.contains('remote-submix') || id == 25) {
      return AudioSource('Android Auto', raw, known: true);
    }
    if (isBt) return AudioSource('Bluetooth', raw, known: true);
    if (id == 2) return AudioSource('Altavoz del teléfono', raw, known: true);
    if (id == 11 || id == 12) return AudioSource('USB', raw, known: true);
    return AudioSource('Origen no reconocido', raw, known: false);
  }
}
