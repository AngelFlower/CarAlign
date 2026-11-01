import 'package:flutter/material.dart';

import '../../../../domain/entities/measurement.dart';
import '../../../../i18n/strings.g.dart';
import '../../../localization/domain_l10n.dart';

class MeasuringCard extends StatelessWidget {
  const MeasuringCard({super.key, required this.phase, required this.fraction});

  final MeasurementPhase phase;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Icon(Icons.graphic_eq, size: 56, color: colors.onPrimaryContainer),
          const SizedBox(height: 12),
          Text(
            t.home.measuring.title(phase: phase.label),
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: fraction > 0 ? fraction : null, minHeight: 14),
          ),
          const SizedBox(height: 16),
          Text(t.home.measuring.stayStill, style: text.titleMedium?.copyWith(color: colors.onPrimaryContainer)),
        ],
      ),
    );
  }
}
