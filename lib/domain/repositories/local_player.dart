import '../entities/delay_setting.dart';
import '../entities/player_snapshot.dart';
import '../entities/track.dart';

/// The built-in music player, whose output goes through the channel delay.
abstract interface class LocalPlayer {
  /// Opens the system file picker and returns the audio files the user chose (empty if cancelled).
  Future<List<Track>> pickTracks();

  Future<void> add(List<Track> tracks);

  /// Loads a saved queue without playing it; ignored when the player already has one.
  Future<void> restore(List<Track> tracks);

  Future<void> remove(int index);

  Future<void> clear();

  Future<void> playIndex(int index);

  Future<void> togglePlay();

  Future<void> next();

  Future<void> previous();

  Future<void> seekTo(int positionMs);

  Future<PlayerSnapshot> snapshot();

  /// Sets the delay the player applies, optionally sliding to it over [rampSeconds].
  Future<void> setPlayerDelay(DelaySetting delay, {double? rampSeconds});
}
