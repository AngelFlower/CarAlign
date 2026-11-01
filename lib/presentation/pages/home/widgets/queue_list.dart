import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/player_controller.dart';

/// The queue: tap to play, swipe to remove.
class QueueList extends StatelessWidget {
  const QueueList({super.key, required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.home.player;
    final current = player.snapshot.index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(tr.queue, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: player.addTracks,
              icon: const Icon(Icons.add),
              label: Text(tr.addMore),
            ),
            IconButton(tooltip: tr.clearQueue, onPressed: player.clear, icon: const Icon(Icons.clear_all)),
          ],
        ),
        for (var i = 0; i < player.tracks.length; i++)
          Dismissible(
            key: ValueKey('${player.tracks[i].uri}#$i'),
            background: Container(color: colors.errorContainer),
            onDismissed: (_) => player.removeAt(i),
            child: ListTile(
              minTileHeight: 60,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              selected: i == current,
              leading: Icon(i == current && player.snapshot.playing ? Icons.graphic_eq : Icons.music_note),
              title: Text(player.tracks[i].title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                [
                  if (player.tracks[i].artist.isNotEmpty) player.tracks[i].artist,
                  if (player.tracks[i].durationMs > 0) formatDuration(player.tracks[i].durationMs),
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => player.playIndex(i),
            ),
          ),
        Text(tr.queueHint, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}
