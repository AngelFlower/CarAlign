import 'package:flutter/material.dart';

/// A framed illustration with a caption.
class FigureCard extends StatelessWidget {
  const FigureCard({super.key, required this.painter, required this.caption});

  final CustomPainter painter;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        children: [
          AspectRatio(aspectRatio: 1.6, child: CustomPaint(painter: painter)),
          const SizedBox(height: 6),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
