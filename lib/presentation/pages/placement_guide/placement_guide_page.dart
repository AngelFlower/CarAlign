import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';
import 'widgets/car_checklist.dart';
import 'widgets/figure_card.dart';
import 'widgets/guide_step.dart';
import 'widgets/side_view_painter.dart';
import 'widgets/top_view_painter.dart';

/// How to place the phone. With [firstRun] it shows the "Don't show again" box and pops
/// `(start: true, hide: …)` when the user taps "Got it, start".
class PlacementGuidePage extends StatefulWidget {
  const PlacementGuidePage({super.key, this.firstRun = false, this.hideGuide = false});

  final bool firstRun;
  final bool hideGuide;

  @override
  State<PlacementGuidePage> createState() => _PlacementGuidePageState();
}

class _PlacementGuidePageState extends State<PlacementGuidePage> {
  late bool _hide = widget.hideGuide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final tr = t.placement;
    return Scaffold(
      appBar: AppBar(title: Text(tr.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            FigureCard(painter: TopViewPainter(theme.colorScheme, dark), caption: tr.topCaption),
            const SizedBox(height: 12),
            FigureCard(painter: SideViewPainter(theme.colorScheme, dark), caption: tr.sideCaption),
            const SizedBox(height: 20),
            GuideStep(icon: Icons.headphones, number: 1, title: tr.step1Title, body: tr.step1Body),
            GuideStep(icon: Icons.mic, number: 2, title: tr.step2Title, body: tr.step2Body),
            GuideStep(icon: Icons.pan_tool_alt_outlined, number: 3, title: tr.step3Title, body: tr.step3Body),
            const SizedBox(height: 8),
            const CarChecklist(),
            const SizedBox(height: 16),
            Text(
              widget.firstRun ? tr.firstRunInfo : tr.info,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (widget.firstRun) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _hide,
                onChanged: (v) => setState(() => _hide = v ?? false),
                title: Text(tr.dontShowAgain),
                subtitle: Text(tr.dontShowAgainHint),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
                onPressed: () => Navigator.pop(context, (start: true, hide: _hide)),
                child: Text(tr.gotIt, style: const TextStyle(fontSize: 18)),
              ),
            ] else
              FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: () => Navigator.pop(context),
                child: Text(t.common.close),
              ),
          ],
        ),
      ),
    );
  }
}
