import 'audio_source.dart';
import 'channel_side.dart';
import 'delay_setting.dart';

enum ResultStatus { ok, warn, fail }

enum Band { broad, low, mid, high }

/// Why a measurement was not reliable.
enum ReasonCode { fewValidReps, lowRepeatability, recordingTooShort, recordingSilent, unknown }

class Reason {
  const Reason(this.code, [this.value = 0]);

  final ReasonCode code;
  final num value;
}

enum ResultMessageCode {
  speakerOutput,
  bluetoothCallLine,
  noSignal,
  clipped,
  measurementUnreliable,
  verificationUnreliable,
  differenceTooLarge,
  notVerifiable,
  identicalChannels,
  notConverging,
  notConvergingRejected,
  internalError,
  unknown,
}

/// A user-facing note produced by the alignment flow; text is localized in the presentation layer.
class ResultMessage {
  const ResultMessage(this.code, {this.reason, this.value = 0, this.text = ''});

  final ResultMessageCode code;
  final Reason? reason;
  final num value;
  final String text;
}

/// Outcome of one automatic alignment run.
class AlignmentResult {
  const AlignmentResult({
    required this.status,
    required this.apply,
    required this.delayLeftMs,
    required this.delayRightMs,
    required this.residualUs,
    required this.sigmaUs,
    required this.validRepetitions,
    required this.repetitions,
    required this.band,
    required this.source,
    required this.inputDevice,
    required this.noiseDbfs,
    required this.wasPlaying,
    required this.messages,
    this.bandDeltasMs,
  });

  final ResultStatus status;
  final bool apply;
  final double delayLeftMs, delayRightMs;
  final double residualUs, sigmaUs;
  final int validRepetitions, repetitions;
  final Band? band;
  final AudioSource source;
  final String inputDevice;
  final double noiseDbfs;

  /// Whether music was playing before the measurement paused it.
  final bool wasPlaying;
  final List<ResultMessage> messages;

  /// R−L arrival difference without delay, per band; null when a band could not be measured.
  final Map<Band, double?>? bandDeltasMs;

  /// The delay to apply, or null when the result is not applicable.
  DelaySetting? get delay {
    if (!apply) return null;
    final left = delayLeftMs > 0;
    return DelaySetting(left ? delayLeftMs : delayRightMs, left ? ChannelSide.left : ChannelSide.right);
  }
}
