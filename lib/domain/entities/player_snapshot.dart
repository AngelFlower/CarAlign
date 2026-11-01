/// What the built-in player is doing right now.
class PlayerSnapshot {
  const PlayerSnapshot({
    this.connected = false,
    this.playing = false,
    this.index = 0,
    this.positionMs = 0,
    this.durationMs = 0,
    this.queueSize = 0,
  });

  final bool connected, playing;
  final int index, positionMs, durationMs, queueSize;

  @override
  bool operator ==(Object other) =>
      other is PlayerSnapshot &&
      other.connected == connected &&
      other.playing == playing &&
      other.index == index &&
      other.positionMs == positionMs &&
      other.durationMs == durationMs &&
      other.queueSize == queueSize;

  @override
  int get hashCode => Object.hash(connected, playing, index, positionMs, durationMs, queueSize);
}
