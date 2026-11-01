import 'channel_side.dart';
import 'delay_setting.dart';

/// A named, saved delay setting.
class Profile {
  const Profile(this.name, this.delay);

  final String name;
  final DelaySetting delay;

  Map<String, dynamic> toJson() => {'name': name, 'ms': delay.milliseconds, 'left': delay.side == ChannelSide.left};

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    json['name'] as String,
    DelaySetting((json['ms'] as num).toDouble(), (json['left'] as bool) ? ChannelSide.left : ChannelSide.right),
  );
}
