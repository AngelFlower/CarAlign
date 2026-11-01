import '../entities/alignment_result.dart';
import '../entities/delay_setting.dart';
import '../repositories/audio_engine.dart';

/// Puts a measured delay into effect and brings the music back if the measurement paused it.
class ApplyAlignment {
  ApplyAlignment(this._engine);

  final AudioEngine _engine;

  Future<void> call(AlignmentResult result, DelaySetting delay) async {
    await _engine.start(delay);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (result.wasPlaying) {
      // The guard needs ~1 s to mute the original: resume afterwards so nothing is heard twice.
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await _engine.resumeMedia();
    }
  }
}
