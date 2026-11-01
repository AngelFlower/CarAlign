/// Where the phone's audio is being played, derived from the audio output descriptor.
enum AudioSourceKind { androidAuto, bluetooth, phoneSpeaker, usb, unrecognized, unknown }

class AudioSource {
  const AudioSource(this.kind, this.raw);

  final AudioSourceKind kind;

  /// Raw descriptor reported by the native layer, e.g. `25:remote-submix`.
  final String raw;

  static const _bluetoothIds = {7, 8, 26, 27, 30};

  /// Classifies the `out` field of a measurement result.
  factory AudioSource.parse(String? out) {
    final raw = (out ?? '').trim();
    if (raw.isEmpty) return const AudioSource(AudioSourceKind.unknown, '');
    final lower = raw.toLowerCase();
    final id = int.tryParse(RegExp(r'^\s*(\d+)').firstMatch(raw)?.group(1) ?? '');
    final isBluetooth =
        lower.contains('bluetooth') ||
        lower.contains('a2dp') ||
        RegExp(r'(^|[^a-z])bt([^a-z]|$)').hasMatch(lower) ||
        _bluetoothIds.contains(id);
    if (lower.contains('remote-submix') || id == 25) {
      return AudioSource(AudioSourceKind.androidAuto, raw);
    }
    if (isBluetooth) return AudioSource(AudioSourceKind.bluetooth, raw);
    if (id == 2) return AudioSource(AudioSourceKind.phoneSpeaker, raw);
    if (id == 11 || id == 12) return AudioSource(AudioSourceKind.usb, raw);
    return AudioSource(AudioSourceKind.unrecognized, raw);
  }
}
