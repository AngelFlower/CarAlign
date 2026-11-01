import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../domain/entities/channel_side.dart';
import '../../../../domain/entities/delay_setting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/alignment_controller.dart';

class ManualAdjustSection extends StatelessWidget {
  const ManualAdjustSection({super.key, required this.alignment});

  final AlignmentController alignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.advanced.manual;
    final delay = alignment.delay;
    final ms = delay.milliseconds;
    void nudge(double by) => alignment.setMilliseconds(ms + by);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr.title, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(tr.subtitle, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(t.common.millisecondsValue(value: formatMs(ms)), style: text.displayMedium),
                Text(
                  tr.difference(cm: formatFixed(delay.centimeters, 1)),
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: ms,
                  min: 0,
                  max: DelaySetting.maxMilliseconds,
                  divisions: 500,
                  onChanged: alignment.setMilliseconds,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(iconSize: 28, onPressed: () => nudge(-0.1), icon: const Icon(Icons.remove)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      iconSize: 28,
                      onPressed: () => nudge(-0.02),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      iconSize: 28,
                      onPressed: () => nudge(0.02),
                      icon: const Icon(Icons.chevron_right),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(iconSize: 28, onPressed: () => nudge(0.1), icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<ChannelSide>(
                  segments: [
                    ButtonSegment(value: ChannelSide.left, label: Text(tr.delayLeft)),
                    ButtonSegment(value: ChannelSide.right, label: Text(tr.delayRight)),
                  ],
                  selected: {delay.side},
                  onSelectionChanged: (v) => alignment.setSide(v.first),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
