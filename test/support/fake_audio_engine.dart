import 'package:caralign/domain/entities/alignment_result.dart';
import 'package:caralign/domain/entities/audio_source.dart';
import 'package:caralign/domain/entities/delay_setting.dart';
import 'package:caralign/domain/entities/guard_status.dart';
import 'package:caralign/domain/entities/measurement.dart';
import 'package:caralign/domain/entities/player_snapshot.dart';
import 'package:caralign/domain/entities/track.dart';
import 'package:caralign/domain/repositories/audio_engine.dart';
import 'package:caralign/domain/repositories/local_player.dart';

/// Records every call so use cases can be tested without Android.
class FakeAudioEngine implements AudioEngine, LocalPlayer {
  final calls = <String>[];
  final delays = <DelaySetting>[];
  final earcons = <Earcon>[];
  final playerDelays = <DelaySetting>[];
  var playing = false;
  var polls = 0;
  AlignmentResult result = fakeResult();

  static AlignmentResult fakeResult({bool apply = true, bool wasPlaying = false}) => AlignmentResult(
    status: apply ? ResultStatus.ok : ResultStatus.fail,
    apply: apply,
    delayLeftMs: apply ? 1.1 : 0,
    delayRightMs: 0,
    residualUs: 12,
    sigmaUs: 20,
    validRepetitions: 10,
    repetitions: 10,
    band: Band.broad,
    source: const AudioSource(AudioSourceKind.androidAuto, '25:remote-submix'),
    inputDevice: '15:Built-in mic',
    noiseDbfs: -60,
    wasPlaying: wasPlaying,
    messages: const [],
  );

  @override
  Future<void> start(DelaySetting delay) async {
    calls.add('start');
    delays.add(delay);
  }

  @override
  Future<void> setDelay(DelaySetting delay, {double? rampSeconds}) async {
    calls.add('setDelay');
    delays.add(delay);
  }

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<bool> isActive() async => false;

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<bool> hasMicrophonePermission() async => true;

  @override
  Future<GuardStatus> guardStatus() async => const GuardStatus(alive: true, state: GuardState.alive);

  @override
  Future<void> ensureGuard() async {}

  @override
  Future<CaptureNotice?> takeCaptureNotice() async => null;

  @override
  Future<void> keepScreenOn(bool on) async => calls.add('screenOn:$on');

  @override
  Future<void> playEarcon(Earcon earcon) async => earcons.add(earcon);

  @override
  Future<void> resumeMedia() async => calls.add('resumeMedia');

  @override
  Future<bool> startMeasurement() async {
    calls.add('startMeasurement');
    return true;
  }

  @override
  Future<MeasurementStatus> measurementStatus() async {
    polls++;
    final done = polls >= 2;
    return MeasurementStatus(
      phase: done ? MeasurementPhase.done : MeasurementPhase.measuring,
      fraction: done ? 1 : 0.5,
      done: done,
      result: done ? result : null,
    );
  }

  // ---- built-in player ----

  @override
  Future<List<Track>> pickTracks() async => const [];

  @override
  Future<void> add(List<Track> tracks) async => calls.add('add');

  @override
  Future<void> restore(List<Track> tracks) async => calls.add('restore');

  @override
  Future<void> remove(int index) async => calls.add('remove');

  @override
  Future<void> clear() async => calls.add('clear');

  @override
  Future<void> playIndex(int index) async => playing = true;

  @override
  Future<void> togglePlay() async {
    playing = !playing;
    calls.add('togglePlay');
  }

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<void> seekTo(int positionMs) async {}

  @override
  Future<PlayerSnapshot> snapshot() async => PlayerSnapshot(connected: true, playing: playing, queueSize: 1);

  @override
  Future<void> setPlayerDelay(DelaySetting delay, {double? rampSeconds}) async {
    calls.add('setPlayerDelay');
    playerDelays.add(delay);
  }
}
