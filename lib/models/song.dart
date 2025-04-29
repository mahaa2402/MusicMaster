class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String assetPath;
  final int duration; // Duration in seconds
  final String album;
  
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.assetPath,
    required this.duration,
    required this.album,
  });
  
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      albumArt: json['albumArt'],
      assetPath: json['assetPath'],
      duration: json['duration'],
      album: json['album'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'assetPath': assetPath,
      'duration': duration,
      'album': album,
    };
  }
}
