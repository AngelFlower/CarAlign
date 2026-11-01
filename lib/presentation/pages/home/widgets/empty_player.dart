import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// Shown before any song is added: explains the player and offers the file picker.
class EmptyPlayer extends StatelessWidget {
  const EmptyPlayer({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.library_music_outlined, size: 48, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            t.home.player.emptyTitle,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            t.home.player.emptySubtitle,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(t.home.player.addMusic),
          ),
        ],
      ),
    );
  }
}
