import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/player_controller.dart';

/// The song being played with its seek bar and transport controls.
class PlayerCard extends StatefulWidget {
  const PlayerCard({super.key, required this.player});

  final PlayerController player;

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  /// Position while the thumb is being dragged, so the bar doesn't jump back to the polled value.
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final player = widget.player;
    final snap = player.snapshot;
    final track = player.current;
    final duration = snap.durationMs > 0 ? snap.durationMs : (track?.durationMs ?? 0);
    final position = (_dragging ?? snap.positionMs.toDouble()).clamp(0, duration > 0 ? duration.toDouble() : 1);
    final tr = t.home.player;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            track?.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleLarge?.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
          Text(
            track == null || track.artist.isEmpty ? tr.unknownArtist : track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyLarge?.copyWith(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          Slider(
            value: position.toDouble(),
            min: 0,
            max: duration > 0 ? duration.toDouble() : 1,
            onChanged: duration > 0 ? (v) => setState(() => _dragging = v) : null,
            onChangeEnd: (v) {
              setState(() => _dragging = null);
              player.seekTo(v.round());
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              tr.time(position: formatDuration(position.round()), duration: formatDuration(duration)),
              style: text.bodySmall?.copyWith(color: colors.onPrimaryContainer),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: tr.previous,
                iconSize: 36,
                onPressed: player.previous,
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                tooltip: snap.playing ? tr.pause : tr.play,
                iconSize: 44,
                style: IconButton.styleFrom(minimumSize: const Size(72, 72)),
                onPressed: player.togglePlay,
                icon: Icon(snap.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: tr.next,
                iconSize: 36,
                onPressed: player.next,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
