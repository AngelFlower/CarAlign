import 'package:flutter/widgets.dart';

import '../data/platform/method_channel_audio_engine.dart';
import '../data/storage/shared_prefs_profile_repository.dart';
import '../data/storage/shared_prefs_queue_repository.dart';
import '../data/storage/shared_prefs_settings_repository.dart';
import '../domain/repositories/diagnostics_repository.dart';
import '../domain/usecases/apply_alignment.dart';
import '../domain/usecases/run_auto_alignment.dart';
import '../domain/usecases/run_demo.dart';
import '../presentation/controllers/alignment_controller.dart';
import '../presentation/controllers/auto_align_controller.dart';
import '../presentation/controllers/demo_controller.dart';
import '../presentation/controllers/player_controller.dart';
import '../presentation/controllers/system_status_controller.dart';

/// Wires the layers together once and exposes the controllers to the widget tree.
class AppDependencies {
  AppDependencies({required void Function(String message) onMessage}) {
    final engine = MethodChannelAudioEngine();
    diagnostics = engine;
    status = SystemStatusController(engine);
    player = PlayerController(player: engine, queue: SharedPrefsQueueRepository());
    alignment = AlignmentController(
      engine: engine,
      player: engine,
      profiles: SharedPrefsProfileRepository(),
      settings: SharedPrefsSettingsRepository(),
      status: status,
    );
    autoAlign = AutoAlignController(
      run: RunAutoAlignment(engine),
      apply: ApplyAlignment(engine),
      alignment: alignment,
      status: status,
    );
    demo = DemoController(
      run: RunDemo(engine, engine),
      alignment: alignment,
      player: player,
      status: status,
      onMessage: onMessage,
    );
  }

  late final DiagnosticsRepository diagnostics;
  late final SystemStatusController status;
  late final PlayerController player;
  late final AlignmentController alignment;
  late final AutoAlignController autoAlign;
  late final DemoController demo;

  void dispose() {
    demo.dispose();
    autoAlign.dispose();
    alignment.dispose();
    player.dispose();
    status.dispose();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.dependencies;

  @override
  bool updateShouldNotify(AppScope old) => dependencies != old.dependencies;
}
