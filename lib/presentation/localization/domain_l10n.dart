import '../../domain/entities/alignment_result.dart';
import '../../domain/entities/audio_source.dart';
import '../../domain/entities/channel_side.dart';
import '../../domain/entities/guard_status.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/usecases/run_demo.dart';
import '../../i18n/strings.g.dart';

/// Turns domain values into localized text. Native code and the domain layer only ever carry codes.
extension ChannelSideL10n on ChannelSide {
  String get label => this == ChannelSide.left ? t.common.sideLeft : t.common.sideRight;

  String get shortLabel => this == ChannelSide.left ? t.common.sideLeftShort : t.common.sideRightShort;
}

extension AudioSourceL10n on AudioSource {
  String get name => switch (kind) {
    AudioSourceKind.androidAuto => t.audioSource.androidAuto,
    AudioSourceKind.bluetooth => t.audioSource.bluetooth,
    AudioSourceKind.phoneSpeaker => t.audioSource.phoneSpeaker,
    AudioSourceKind.usb => t.audioSource.usb,
    AudioSourceKind.unrecognized => t.audioSource.unrecognized,
    AudioSourceKind.unknown => t.audioSource.unknown,
  };

  /// One line telling where the measurement came from; empty when there is nothing to say.
  String get measuredLine => switch (kind) {
    AudioSourceKind.androidAuto || AudioSourceKind.bluetooth => t.home.result.measuredVia(name: name),
    AudioSourceKind.phoneSpeaker => t.home.result.measuredPhoneSpeaker,
    AudioSourceKind.usb => t.home.result.measuredUsb,
    AudioSourceKind.unrecognized => t.home.result.sourceUnrecognized,
    AudioSourceKind.unknown => '',
  };
}

extension BandL10n on Band {
  String get label => switch (this) {
    Band.broad => t.band.broad,
    Band.low => t.band.low,
    Band.mid => t.band.mid,
    Band.high => t.band.high,
  };
}

extension MeasurementPhaseL10n on MeasurementPhase {
  String get label => switch (this) {
    MeasurementPhase.preparing => t.phase.preparing,
    MeasurementPhase.adjustingLevel => t.phase.adjustingLevel,
    MeasurementPhase.measuring => t.phase.measuring,
    MeasurementPhase.verifying => t.phase.verifying,
    MeasurementPhase.stoppingCapture => t.phase.stoppingCapture,
    MeasurementPhase.done => t.phase.done,
  };
}

extension CaptureNoticeL10n on CaptureNotice {
  String get text => switch (this) {
    CaptureNotice.captureBlocked => t.notice.captureBlocked,
  };
}

extension DemoStageL10n on DemoStage {
  String get label => switch (this) {
    DemoStage.unaligned => t.advanced.demo.unaligned,
    DemoStage.centering => t.advanced.demo.centering,
    DemoStage.aligned => t.advanced.demo.aligned,
    DemoStage.removing => t.advanced.demo.removing,
  };
}

extension DemoFrameL10n on DemoFrame {
  String get description =>
      step == 0 ? stage.label : t.advanced.demo.stepOf(label: stage.label, k: step, n: totalSteps);
}

extension GuardDetailL10n on GuardDetail {
  String get text => switch (code) {
    GuardDetailCode.adbInactiveNoShizuku => t.guard.adbInactiveNoShizuku,
    GuardDetailCode.adbFailedNoShizuku => t.guard.adbFailedNoShizuku(error: argument),
    GuardDetailCode.shizukuFailed => t.guard.shizukuFailed(error: argument),
    GuardDetailCode.notStarted => t.guard.notStarted,
  };
}

extension ReasonL10n on Reason {
  String get text => switch (code) {
    ReasonCode.fewValidReps => t.reason.fewValidReps(count: value.round()),
    ReasonCode.lowRepeatability => t.reason.lowRepeatability(us: value.round()),
    ReasonCode.recordingTooShort => t.reason.recordingTooShort,
    ReasonCode.recordingSilent => t.reason.recordingSilent,
    ReasonCode.unknown => t.reason.unknown,
  };
}

extension ResultMessageL10n on ResultMessage {
  String get localized => switch (code) {
    ResultMessageCode.speakerOutput => t.resultMessage.speakerOutput,
    ResultMessageCode.bluetoothCallLine => t.resultMessage.bluetoothCallLine,
    ResultMessageCode.noSignal => t.resultMessage.noSignal,
    ResultMessageCode.clipped => t.resultMessage.clipped,
    ResultMessageCode.measurementUnreliable => t.resultMessage.measurementUnreliable(
      reason: (reason ?? const Reason(ReasonCode.unknown)).text,
    ),
    ResultMessageCode.verificationUnreliable => t.resultMessage.verificationUnreliable(
      reason: (reason ?? const Reason(ReasonCode.unknown)).text,
    ),
    ResultMessageCode.differenceTooLarge => t.resultMessage.differenceTooLarge,
    ResultMessageCode.notVerifiable => t.resultMessage.notVerifiable,
    ResultMessageCode.identicalChannels => t.resultMessage.identicalChannels,
    ResultMessageCode.notConverging => t.resultMessage.notConverging(us: value.round()),
    ResultMessageCode.notConvergingRejected => t.resultMessage.notConvergingRejected(us: value.round()),
    ResultMessageCode.internalError => t.resultMessage.internalError(detail: text),
    ResultMessageCode.unknown => t.resultMessage.unknown(code: text),
  };
}
