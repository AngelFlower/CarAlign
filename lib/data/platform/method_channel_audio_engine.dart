import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/alignment_result.dart';
import '../../domain/entities/channel_side.dart';
import '../../domain/entities/delay_setting.dart';
import '../../domain/entities/guard_status.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/player_snapshot.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/audio_engine.dart';
import '../../domain/repositories/diagnostics_repository.dart';
import '../../domain/repositories/local_player.dart';
import 'alignment_result_mapper.dart';

/// Talks to the Android side over the `caralign` method channel.
class MethodChannelAudioEngine implements AudioEngine, DiagnosticsRepository, LocalPlayer {
  MethodChannelAudioEngine([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('caralign');

  final MethodChannel _channel;

  Map<String, dynamic> _delayArgs(DelaySetting d) => {'delayMs': d.milliseconds, 'left': d.side == ChannelSide.left};

  @override
  Future<void> start(DelaySetting delay) => _channel.invokeMethod('start', _delayArgs(delay));

  @override
  Future<void> setDelay(DelaySetting delay, {double? rampSeconds}) =>
      _channel.invokeMethod('set', {..._delayArgs(delay), if (rampSeconds != null) 'seconds': rampSeconds});

  @override
  Future<void> stop() => _channel.invokeMethod('stop');

  @override
  Future<bool> isActive() async => await _channel.invokeMethod<bool>('active') ?? false;

  @override
  Future<void> requestPermissions() => _channel.invokeMethod('perms');

  @override
  Future<bool> hasMicrophonePermission() async => await _channel.invokeMethod<bool>('hasMic') ?? true;

  @override
  Future<GuardStatus> guardStatus() async {
    final info = await _channel.invokeMethod<Map<dynamic, dynamic>>('guardInfo') ?? const {};
    final state = GuardState.values.asNameMap()[info['state']] ?? GuardState.idle;
    return GuardStatus(
      alive: info['alive'] == true,
      state: state,
      detail: _guardDetail(info['detail'] as String? ?? ''),
    );
  }

  /// Native details look like `code` or `code:argument`.
  GuardDetail? _guardDetail(String raw) {
    if (raw.isEmpty) return null;
    final split = raw.indexOf(':');
    final name = split < 0 ? raw : raw.substring(0, split);
    final code = GuardDetailCode.values.asNameMap()[name];
    if (code == null) return null;
    return GuardDetail(code, split < 0 ? '' : raw.substring(split + 1));
  }

  @override
  Future<void> ensureGuard() => _channel.invokeMethod('guardEnsure');

  @override
  Future<CaptureNotice?> takeCaptureNotice() async {
    final code = await _channel.invokeMethod<String>('captureNotice') ?? '';
    return CaptureNotice.values.asNameMap()[code];
  }

  @override
  Future<void> keepScreenOn(bool on) => _channel.invokeMethod('keepScreenOn', on);

  @override
  Future<void> playEarcon(Earcon earcon) => _channel.invokeMethod('earcon', earcon.index);

  @override
  Future<void> resumeMedia() => _channel.invokeMethod('mediaPlay');

  @override
  Future<bool> startMeasurement() async => await _channel.invokeMethod<bool>('autoStart') ?? false;

  @override
  Future<MeasurementStatus> measurementStatus() async {
    final st = await _channel.invokeMethod<Map<dynamic, dynamic>>('autoStatus') ?? const {};
    final done = st['done'] == true;
    final raw = st['result'] as String? ?? '';
    AlignmentResult? result;
    if (done && raw.isNotEmpty) {
      result = AlignmentResultMapper.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return MeasurementStatus(
      phase: MeasurementPhase.values.asNameMap()[st['phase']] ?? MeasurementPhase.preparing,
      fraction: (st['frac'] as num?)?.toDouble() ?? 0,
      done: done,
      result: result,
    );
  }

  @override
  Future<String> report() async => await _channel.invokeMethod<String>('diagnostics') ?? '';

  @override
  Future<String> testMute() async => await _channel.invokeMethod<String>('testMute') ?? '';

  @override
  Future<void> openBatterySettings() => _channel.invokeMethod('batteryExempt');

  // ---- built-in player ----

  @override
  Future<List<Track>> pickTracks() async {
    final picked = await _channel.invokeMethod<List<dynamic>>('pickAudio') ?? const [];
    return [for (final m in picked) Track.fromJson(m as Map<dynamic, dynamic>)];
  }

  List<Map<String, dynamic>> _trackArgs(List<Track> tracks) => [for (final t in tracks) t.toJson()];

  @override
  Future<void> add(List<Track> tracks) => _channel.invokeMethod('playerAdd', _trackArgs(tracks));

  @override
  Future<void> restore(List<Track> tracks) => _channel.invokeMethod('playerRestore', _trackArgs(tracks));

  @override
  Future<void> remove(int index) => _channel.invokeMethod('playerRemove', index);

  @override
  Future<void> clear() => _channel.invokeMethod('playerClear');

  @override
  Future<void> playIndex(int index) => _channel.invokeMethod('playerPlayIndex', index);

  @override
  Future<void> togglePlay() => _channel.invokeMethod('playerToggle');

  @override
  Future<void> next() => _channel.invokeMethod('playerNext');

  @override
  Future<void> previous() => _channel.invokeMethod('playerPrevious');

  @override
  Future<void> seekTo(int positionMs) => _channel.invokeMethod('playerSeek', positionMs);

  @override
  Future<PlayerSnapshot> snapshot() async {
    final s = await _channel.invokeMethod<Map<dynamic, dynamic>>('playerState') ?? const {};
    return PlayerSnapshot(
      connected: s['connected'] == true,
      playing: s['playing'] == true,
      index: (s['index'] as num? ?? 0).toInt(),
      positionMs: (s['positionMs'] as num? ?? 0).toInt(),
      durationMs: (s['durationMs'] as num? ?? 0).toInt(),
      queueSize: (s['queueSize'] as num? ?? 0).toInt(),
    );
  }

  @override
  Future<void> setPlayerDelay(DelaySetting delay, {double? rampSeconds}) =>
      _channel.invokeMethod('playerSetDelay', {..._delayArgs(delay), if (rampSeconds != null) 'seconds': rampSeconds});
}
