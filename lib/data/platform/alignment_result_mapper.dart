import '../../domain/entities/alignment_result.dart';
import '../../domain/entities/audio_source.dart';

/// Converts the JSON produced by the native measurement into domain objects.
class AlignmentResultMapper {
  const AlignmentResultMapper._();

  static const _bandKeys = {
    'broad': Band.broad,
    'low': Band.low,
    'mid': Band.mid,
    'high': Band.high,
  };

  static AlignmentResult fromJson(Map<String, dynamic> json) {
    final bandDeltas = json['bandsMs'] as Map<String, dynamic>?;
    return AlignmentResult(
      status: switch (json['status']) {
        'OK' => ResultStatus.ok,
        'WARN' => ResultStatus.warn,
        _ => ResultStatus.fail,
      },
      apply: json['apply'] == true,
      delayLeftMs: (json['delayLeftMs'] as num? ?? 0).toDouble(),
      delayRightMs: (json['delayRightMs'] as num? ?? 0).toDouble(),
      residualUs: (json['residualUs'] as num? ?? 0).toDouble(),
      sigmaUs: (json['sigmaUs'] as num? ?? 0).toDouble(),
      validRepetitions: (json['valid'] as num? ?? 0).toInt(),
      repetitions: (json['reps'] as num? ?? 10).toInt(),
      band: _bandKeys[json['band']],
      source: AudioSource.parse(json['out'] as String?),
      inputDevice: json['in'] as String? ?? '?',
      noiseDbfs: (json['noiseDbfs'] as num? ?? 0).toDouble(),
      wasPlaying: json['wasPlaying'] == true,
      messages: [for (final m in (json['messages'] as List? ?? const [])) _message(m as Map<String, dynamic>)],
      bandDeltasMs: bandDeltas == null
          ? null
          : {for (final e in _bandKeys.entries) e.value: (bandDeltas[e.key] as num?)?.toDouble()},
    );
  }

  static ResultMessage _message(Map<String, dynamic> json) {
    final code = ResultMessageCode.values.asNameMap()[json['code']] ?? ResultMessageCode.unknown;
    final reason = json['reason'] as String?;
    return ResultMessage(
      code,
      reason: reason == null
          ? null
          : Reason(ReasonCode.values.asNameMap()[reason] ?? ReasonCode.unknown, json['value'] as num? ?? 0),
      value: json['value'] as num? ?? 0,
      text: json['text'] as String? ?? (code == ResultMessageCode.unknown ? '${json['code']}' : ''),
    );
  }
}
