import 'package:my_music_stream/models/song.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverImagePath;
  final List<String> songIds; // List of song IDs
  final DateTime createdAt;
  
  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverImagePath,
    required this.songIds,
    required this.createdAt,
  });
  
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverImagePath: json['coverImagePath'],
      songIds: List<String>.from(json['songIds']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImagePath': coverImagePath,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Add a song to playlist
  Playlist addSong(String songId) {
    if (songIds.contains(songId)) return this;
    
    List<String> newSongIds = List.from(songIds);
    newSongIds.add(songId);
    
    return Playlist(
      id: id,
      name: name,
      description: description,
      coverImagePath: coverImagePath,
      songIds: newSongIds,
      createdAt: createdAt,
    );
  }
  
  // Remove a song from playlist
  Playlist removeSong(String songId) {
    if (!songIds.contains(songId)) return this;
    
    List<String> newSongIds = List.from(songIds);
    newSongIds.remove(songId);
    
    return Playlist(
      id: id,
      name: name,
      description: description,
      coverImagePath: coverImagePath,
      songIds: newSongIds,
      createdAt: createdAt,
    );
  }
}
