class User {
  final String id;
  final String username;
  final String email;
  final String? profileImagePath;
  final List<String> likedSongIds;
  final List<String> recentlyPlayedIds;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImagePath,
    required this.likedSongIds,
    required this.recentlyPlayedIds,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImagePath: json['profileImagePath'],
      likedSongIds: List<String>.from(json['likedSongIds']),
      recentlyPlayedIds: List<String>.from(json['recentlyPlayedIds']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImagePath': profileImagePath,
      'likedSongIds': likedSongIds,
      'recentlyPlayedIds': recentlyPlayedIds,
    };
  }
  
  // Create a new user with updated likedSongIds
  User toggleLikedSong(String songId) {
    List<String> newLikedSongIds = List.from(likedSongIds);
    
    if (newLikedSongIds.contains(songId)) {
      newLikedSongIds.remove(songId);
    } else {
      newLikedSongIds.add(songId);
    }
    
    return User(
      id: id,
      username: username,
      email: email,
      profileImagePath: profileImagePath,
      likedSongIds: newLikedSongIds,
      recentlyPlayedIds: recentlyPlayedIds,
    );
  }
  
  // Add song to recently played
  User addToRecentlyPlayed(String songId) {
    List<String> newRecentlyPlayedIds = List.from(recentlyPlayedIds);
    
    // Remove if already exists to avoid duplicates
    if (newRecentlyPlayedIds.contains(songId)) {
      newRecentlyPlayedIds.remove(songId);
    }
    
    // Add to the beginning
    newRecentlyPlayedIds.insert(0, songId);
    
    // Keep only the most recent 20 songs
    if (newRecentlyPlayedIds.length > 20) {
      newRecentlyPlayedIds = newRecentlyPlayedIds.sublist(0, 20);
    }
    
    return User(
      id: id,
      username: username,
      email: email,
      profileImagePath: profileImagePath,
      likedSongIds: likedSongIds,
      recentlyPlayedIds: newRecentlyPlayedIds,
    );
  }
}
