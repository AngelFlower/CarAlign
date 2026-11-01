import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// Conditions to check in the car before measuring.
class CarChecklist extends StatelessWidget {
  const CarChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = [
      t.placement.car1,
      t.placement.car2,
      t.placement.car3,
      t.placement.car4,
      t.placement.car5,
      t.placement.car6,
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.placement.carTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.check_circle_outline, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
            ]),
          ),
        const SizedBox(height: 6),
        Text(t.placement.rearWarning,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      ]),
    );
  }
}
