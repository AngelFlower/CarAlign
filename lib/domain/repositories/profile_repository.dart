import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<List<Profile>> load();

  Future<void> save(List<Profile> profiles);
}
