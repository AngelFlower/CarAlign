import 'package:caralign/data/platform/alignment_result_mapper.dart';
import 'package:caralign/domain/entities/alignment_result.dart';
import 'package:caralign/domain/entities/audio_source.dart';
import 'package:caralign/domain/entities/channel_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps an applied result with its messages and band deltas', () {
    final r = AlignmentResultMapper.fromJson({
      'status': 'WARN',
      'apply': true,
      'delayLeftMs': 1.25,
      'delayRightMs': 0,
      'residualUs': 55.4,
      'sigmaUs': 30,
      'valid': 9,
      'reps': 10,
      'band': 'low',
      'out': '25:remote-submix',
      'in': '15:Built-in mic',
      'noiseDbfs': -58.2,
      'wasPlaying': true,
      'bandsMs': {'broad': 1.3, 'low': null, 'mid': 1.2, 'high': 1.1},
      'messages': [
        {'code': 'notConverging', 'value': 120},
        {'code': 'measurementUnreliable', 'reason': 'fewValidReps', 'value': 3},
      ],
    });
    expect(r.status, ResultStatus.warn);
    expect(r.delay!.side, ChannelSide.left);
    expect(r.delay!.milliseconds, 1.25);
    expect(r.band, Band.low);
    expect(r.source.kind, AudioSourceKind.androidAuto);
    expect(r.wasPlaying, isTrue);
    expect(r.bandDeltasMs![Band.low], isNull);
    expect(r.bandDeltasMs![Band.mid], 1.2);
    expect(r.messages[0].code, ResultMessageCode.notConverging);
    expect(r.messages[0].value, 120);
    expect(r.messages[1].reason!.code, ReasonCode.fewValidReps);
    expect(r.messages[1].reason!.value, 3);
  });

  test('a rejected result has no delay and tolerates missing fields', () {
    final r = AlignmentResultMapper.fromJson({
      'status': 'FAIL',
      'apply': false,
      'messages': [
        {'code': 'somethingNew'},
        {'code': 'internalError', 'text': 'boom'},
      ],
    });
    expect(r.delay, isNull);
    expect(r.repetitions, 10);
    expect(r.messages[0].code, ResultMessageCode.unknown);
    expect(r.messages[0].text, 'somethingNew');
    expect(r.messages[1].text, 'boom');
  });

  test('right-channel delay', () {
    final r = AlignmentResultMapper.fromJson({'status': 'OK', 'apply': true, 'delayLeftMs': 0, 'delayRightMs': 0.8});
    expect(r.delay!.side, ChannelSide.right);
    expect(r.delay!.milliseconds, 0.8);
  });
}
