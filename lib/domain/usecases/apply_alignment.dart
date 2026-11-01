import '../entities/alignment_result.dart';
import '../entities/delay_setting.dart';
import '../repositories/audio_engine.dart';

/// Puts a measured delay into effect and brings the music back if the measurement paused it.
class ApplyAlignment {
  ApplyAlignment(this._engine);

  final AudioEngine _engine;

  /// With [viaCapture] the capture of other apps is started with the delay; otherwise the built-in player
  /// already has it and only the paused music has to come back.
  Future<void> call(AlignmentResult result, DelaySetting delay, {required bool viaCapture}) async {
    if (viaCapture) {
      await _engine.start(delay);
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    if (result.wasPlaying) {
      // With capture the guard needs ~1 s to mute the original: resume afterwards so nothing is heard twice.
      await Future<void>.delayed(Duration(milliseconds: viaCapture ? 2500 : 1000));
      await _engine.resumeMedia();
    }
  }
}
