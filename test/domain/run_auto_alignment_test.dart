import 'package:caralign/domain/entities/measurement.dart';
import 'package:caralign/domain/usecases/run_auto_alignment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_audio_engine.dart';

void main() {
  test('counts down, measures and reports the result with cues', () async {
    final engine = FakeAudioEngine();
    final events = await RunAutoAlignment(engine, tick: const Duration(milliseconds: 1))().toList();

    final ticks = events.whereType<CountdownTick>().map((e) => e.secondsLeft).toList();
    expect(ticks.first, RunAutoAlignment.countdownSeconds);
    expect(ticks.last, 0);
    expect(events.last, isA<MeasurementFinished>());
    expect(engine.earcons, [Earcon.tick, Earcon.tick, Earcon.tick, Earcon.go, Earcon.success]);
    expect(engine.calls.first, 'screenOn:true');
    expect(engine.calls.last, 'screenOn:false');
  });

  test('a rejected measurement that paused the music resumes it', () async {
    final engine = FakeAudioEngine()..result = FakeAudioEngine.fakeResult(apply: false, wasPlaying: true);
    await RunAutoAlignment(engine, tick: const Duration(milliseconds: 1))().toList();
    expect(engine.earcons.last, Earcon.failure);
    expect(engine.calls, contains('resumeMedia'));
  });

  test('cancelling the stream still releases the screen', () async {
    final engine = FakeAudioEngine();
    final sub = RunAutoAlignment(engine, tick: const Duration(milliseconds: 50))().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(engine.calls.last, 'screenOn:false');
  });
}
