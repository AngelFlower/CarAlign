import 'package:flutter/material.dart';

import '../../../controllers/player_controller.dart';
import 'empty_player.dart';
import 'player_card.dart';
import 'queue_list.dart';

/// The built-in player: an invitation to add music, or the current song and the queue.
class PlayerSection extends StatelessWidget {
  const PlayerSection({super.key, required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    if (!player.hasTracks) return EmptyPlayer(onAdd: player.addTracks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlayerCard(player: player),
        const SizedBox(height: 12),
        QueueList(player: player),
      ],
    );
  }
}
