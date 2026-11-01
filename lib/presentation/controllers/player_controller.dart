import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/player_snapshot.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/local_player.dart';
import '../../domain/repositories/queue_repository.dart';

/// The built-in player: its queue (kept across restarts) and what it is playing.
class PlayerController extends ChangeNotifier {
  PlayerController({required LocalPlayer player, required QueueRepository queue}) : _player = player, _queue = queue {
    _load();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => refresh());
  }

  final LocalPlayer _player;
  final QueueRepository _queue;
  Timer? _timer;
  bool _disposed = false;

  List<Track> tracks = [];
  PlayerSnapshot snapshot = const PlayerSnapshot();

  bool get hasTracks => tracks.isNotEmpty;

  Track? get current => snapshot.index >= 0 && snapshot.index < tracks.length ? tracks[snapshot.index] : null;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _load() async {
    tracks = await _queue.load();
    await _player.restore(tracks);
    _notify();
  }

  Future<void> refresh() async {
    try {
      final s = await _player.snapshot();
      if (s != snapshot) {
        snapshot = s;
        _notify();
      }
    } catch (_) {
      // The next tick retries.
    }
  }

  /// Lets the user pick songs and appends them to the queue.
  Future<void> addTracks() async {
    final picked = await _player.pickTracks();
    if (picked.isEmpty) return;
    tracks = [...tracks, ...picked];
    await _queue.save(tracks);
    await _player.add(picked);
    _notify();
    await refresh();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= tracks.length) return;
    tracks = [...tracks]..removeAt(index);
    await _queue.save(tracks);
    await _player.remove(index);
    _notify();
    await refresh();
  }

  Future<void> clear() async {
    tracks = [];
    await _queue.save(tracks);
    await _player.clear();
    _notify();
    await refresh();
  }

  Future<void> playIndex(int index) async {
    await _player.playIndex(index);
    await refresh();
  }

  Future<void> togglePlay() async {
    await _player.togglePlay();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await refresh();
  }

  Future<void> next() async {
    await _player.next();
    await refresh();
  }

  Future<void> previous() async {
    await _player.previous();
    await refresh();
  }

  Future<void> seekTo(int positionMs) async {
    await _player.seekTo(positionMs);
    await refresh();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
