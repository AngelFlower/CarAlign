import 'package:caralign/domain/entities/channel_side.dart';
import 'package:caralign/domain/entities/delay_setting.dart';
import 'package:caralign/domain/usecases/run_demo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_audio_engine.dart';

void main() {
  test('stopping mid-ramp freezes the delay where the demo stopped', () async {
    final engine = FakeAudioEngine();
    final session = DemoSession();
    final frames = <DemoFrame>[];
    final target = const DelaySetting(1.2, ChannelSide.left);
    await for (final f in RunDemo(engine, engine)(
      target,
      session,
      loop: false,
      seconds: 3,
      steps: 6,
      viaCapture: true,
      engineActive: true,
    )) {
      frames.add(f);
      if (f.stage == DemoStage.centering && f.step == 2) session.stop();
    }
    final last = frames.last;
    expect(last.stage, DemoStage.centering);
    expect(last.step, 2);
    expect(last.shownMs, closeTo(1.2 * 2 / 6, 1e-9));
    expect(engine.delays.last.milliseconds, closeTo(last.shownMs, 1e-9));
    expect(engine.delays.last.side, ChannelSide.left);
    expect(engine.calls.last, 'screenOn:false');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
