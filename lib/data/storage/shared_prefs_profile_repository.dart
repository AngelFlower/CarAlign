import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class SharedPrefsProfileRepository implements ProfileRepository {
  static const _key = 'profiles';

  @override
  Future<List<Profile>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return [for (final s in raw) Profile.fromJson(jsonDecode(s) as Map<String, dynamic>)];
  }

  @override
  Future<void> save(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, [for (final p in profiles) jsonEncode(p.toJson())]);
  }
}
