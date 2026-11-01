import '../entities/track.dart';

abstract interface class QueueRepository {
  Future<List<Track>> load();

  Future<void> save(List<Track> tracks);
}
