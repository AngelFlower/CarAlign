import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../i18n/strings.g.dart';
import '../../controllers/auto_align_controller.dart';
import '../../localization/domain_l10n.dart';
import '../../widgets/readiness_banner.dart';
import '../advanced/advanced_page.dart';
import '../placement_guide/placement_guide_page.dart';
import 'widgets/align_button.dart';
import 'widgets/countdown_card.dart';
import 'widgets/delay_chip.dart';
import 'widgets/measuring_card.dart';
import 'widgets/player_section.dart';
import 'widgets/profiles_section.dart';
import 'widgets/result_card.dart';
import 'widgets/save_profile_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  StreamSubscription<dynamic>? _notices;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;
    _subscribed = true;
    _notices = AppScope.of(context).status.notices.listen((notice) => _showNotice(notice.text));
  }

  void _showNotice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 12), showCloseIcon: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notices?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) AppScope.of(context).status.refresh();
  }

  /// Shows the placement guide (unless hidden) and then runs the measurement.
  Future<void> _align() async {
    final deps = AppScope.of(context);
    if (!deps.alignment.hidePlacementGuide) {
      final answer = await Navigator.of(
        context,
      ).push<({bool start, bool hide})>(MaterialPageRoute(builder: (_) => const PlacementGuidePage(firstRun: true)));
      if (answer == null || !answer.start || !mounted) return;
      if (answer.hide) await deps.alignment.setHidePlacementGuide(true);
    }
    await deps.autoAlign.start();
  }

  void _openGuide() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PlacementGuidePage(hideGuide: AppScope.of(context).alignment.hidePlacementGuide)),
  );

  void _openAdvanced() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvancedPage()));

  Future<void> _saveProfile() async {
    final name = await showSaveProfileDialog(context);
    if (name == null || name.isEmpty || !mounted) return;
    AppScope.of(context).alignment.addProfile(name);
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([deps.status, deps.alignment, deps.autoAlign, deps.player]),
      builder: (context, _) {
        final auto = deps.autoAlign;
        final alignment = deps.alignment;
        return Scaffold(
          appBar: AppBar(
            title: Text(t.appName, style: const TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: t.home.guideTooltip,
                iconSize: 28,
                onPressed: _openGuide,
                icon: const Icon(Icons.help_outline),
              ),
              IconButton(
                tooltip: t.home.advancedTooltip,
                iconSize: 28,
                onPressed: _openAdvanced,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              ReadinessBanner(status: deps.status, showGuard: alignment.captureMode),
              const SizedBox(height: 8),
              ..._mainSection(auto, deps),
              const SizedBox(height: 28),
              ProfilesSection(alignment: alignment, onSave: _saveProfile),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _mainSection(AutoAlignController auto, AppDependencies deps) {
    switch (auto.phase) {
      case AutoAlignPhase.countdown:
        return [CountdownCard(secondsLeft: auto.secondsLeft)];
      case AutoAlignPhase.measuring:
        return [MeasuringCard(phase: auto.measurementPhase, fraction: auto.fraction)];
      case AutoAlignPhase.idle:
      case AutoAlignPhase.done:
        return [
          PlayerSection(player: deps.player),
          const SizedBox(height: 20),
          DelayChip(alignment: deps.alignment),
          const SizedBox(height: 12),
          AlignButton(
            alreadyAligned: auto.phase == AutoAlignPhase.done || deps.alignment.hasDelay,
            onPressed: auto.busy ? null : _align,
          ),
          if (auto.phase == AutoAlignPhase.done && auto.result != null) ...[
            const SizedBox(height: 16),
            ResultCard(result: auto.result!),
          ],
        ];
    }
  }
}
