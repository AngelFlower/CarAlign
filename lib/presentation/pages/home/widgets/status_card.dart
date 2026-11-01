import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/alignment_controller.dart';
import '../../../localization/domain_l10n.dart';

/// Alignment running (with Stop) or stopped (with Start).
class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.alignment});

  final AlignmentController alignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final on = alignment.active;
    final background = on ? colors.primaryContainer : colors.surfaceContainerHigh;
    final foreground = on ? colors.onPrimaryContainer : colors.onSurface;
    final tr = t.home.status;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(on ? Icons.graphic_eq : Icons.pause_circle_outline, color: foreground, size: 28),
          const SizedBox(width: 10),
          Text(on ? tr.active : tr.stopped,
              style: text.titleMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(tr.value(side: alignment.delay.side.label, ms: formatMs(alignment.delay.milliseconds)),
            style: text.displaySmall?.copyWith(color: foreground, fontWeight: FontWeight.w800)),
        Text(on ? tr.processing : tr.lastSaved, style: text.bodyLarge?.copyWith(color: foreground)),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(64),
            backgroundColor: on ? colors.error : colors.primary,
            foregroundColor: on ? colors.onError : colors.onPrimary,
          ),
          onPressed: alignment.toggle,
          icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 30),
          label: Text(on ? t.common.stop : t.common.start),
        ),
      ]),
    );
  }
}
