import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/demo_controller.dart';
import '../../../localization/domain_l10n.dart';

class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.demo});

  final DemoController demo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.advanced.demo;
    final profiles = demo.profiles;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr.title, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(tr.description, style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 12),
            if (profiles.isEmpty)
              Text(tr.needsProfile, style: TextStyle(color: colors.onSurfaceVariant))
            else if (demo.running)
              ..._running(context)
            else
              ..._idle(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _running(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final target = demo.profiles[demo.selectedIndex].delay.milliseconds;
    return [
      Center(
        child: Text(t.common.millisecondsValue(value: formatFixed(demo.frame.shownMs, 2)), style: text.displaySmall),
      ),
      Center(child: Text(demo.frame.description)),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: target <= 0 ? 0 : (demo.frame.shownMs / target).clamp(0.0, 1.0)),
      const SizedBox(height: 12),
      FilledButton.tonalIcon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        onPressed: demo.stop,
        icon: const Icon(Icons.stop),
        label: Text(t.advanced.demo.stop),
      ),
    ];
  }

  List<Widget> _idle(BuildContext context) {
    final index = demo.selectedIndex;
    final profiles = demo.profiles;
    return [
      DropdownButtonFormField<int>(
        key: ValueKey('demo$index${profiles.length}'),
        initialValue: index,
        decoration: InputDecoration(labelText: t.advanced.demo.profile),
        items: [
          for (var i = 0; i < profiles.length; i++)
            DropdownMenuItem(
              value: i,
              child: Text(
                t.advanced.demo.profileItem(
                  name: profiles[i].name,
                  ms: formatFixed(profiles[i].delay.milliseconds, 2),
                  side: profiles[i].delay.side.shortLabel,
                ),
              ),
            ),
        ],
        onChanged: (v) => demo.selectProfile(v ?? 0),
      ),
      const SizedBox(height: 8),
      _SliderRow(
        label: t.advanced.demo.duration,
        value: demo.seconds,
        min: 3,
        max: 40,
        divisions: 37,
        display: (v) => t.advanced.demo.seconds(n: v.round()),
        onChanged: demo.setSeconds,
      ),
      _SliderRow(
        label: t.advanced.demo.steps,
        value: demo.steps,
        min: 2,
        max: 12,
        divisions: 10,
        display: (v) => '${v.round()}',
        onChanged: demo.setSteps,
      ),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              onPressed: () => demo.play(loop: false),
              icon: const Icon(Icons.play_arrow),
              label: Text(t.advanced.demo.toProfile, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => demo.play(loop: true),
              icon: const Icon(Icons.repeat),
              label: Text(t.advanced.demo.roundTrip, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    ];
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value, min, max;
  final int divisions;
  final String Function(double) display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: display(value),
            onChanged: onChanged,
          ),
        ),
        Text(display(value)),
      ],
    );
  }
}
