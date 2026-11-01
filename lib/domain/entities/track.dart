/// A song the user added to the built-in player.
class Track {
  const Track({required this.uri, required this.title, this.artist = '', this.durationMs = 0});

  /// Content URI the player reads from (access is kept with a persistable permission).
  final String uri;
  final String title;
  final String artist;
  final int durationMs;

  Map<String, dynamic> toJson() => {'uri': uri, 'title': title, 'artist': artist, 'durationMs': durationMs};

  factory Track.fromJson(Map<dynamic, dynamic> json) => Track(
    uri: json['uri'] as String,
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    durationMs: (json['durationMs'] as num? ?? 0).toInt(),
  );
}
