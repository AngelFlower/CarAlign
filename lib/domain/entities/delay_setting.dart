import 'channel_side.dart';

/// A delay applied to one channel of the stereo output.
class DelaySetting {
  const DelaySetting(this.milliseconds, this.side);

  /// Largest delay the audio engine accepts.
  static const maxMilliseconds = 10.0;

  /// Speed of sound (~343 m/s) expressed as centimeters per millisecond.
  static const centimetersPerMillisecond = 34.3;

  final double milliseconds;
  final ChannelSide side;

  double get centimeters => milliseconds * centimetersPerMillisecond;

  /// Rounds to 0.02 ms, the resolution of the manual controls.
  static double snap(double ms) => (ms.clamp(0, maxMilliseconds) * 50).round() / 50;

  DelaySetting copyWith({double? milliseconds, ChannelSide? side}) =>
      DelaySetting(milliseconds ?? this.milliseconds, side ?? this.side);
}
