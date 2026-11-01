import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/track.dart';
import '../../domain/repositories/queue_repository.dart';

class SharedPrefsQueueRepository implements QueueRepository {
  static const _key = 'queue';

  @override
  Future<List<Track>> load() async {
    final raw = (await SharedPreferences.getInstance()).getStringList(_key) ?? const [];
    return [for (final s in raw) Track.fromJson(jsonDecode(s) as Map<String, dynamic>)];
  }

  @override
  Future<void> save(List<Track> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, [for (final t in tracks) jsonEncode(t.toJson())]);
  }
}
