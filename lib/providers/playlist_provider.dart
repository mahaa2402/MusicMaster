import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_music_stream/models/playlist.dart';

class PlaylistProvider with ChangeNotifier {
  List<Playlist> _playlists = [];
  
  List<Playlist> get playlists => _playlists;
  
  PlaylistProvider() {
    _loadPlaylists();
  }
  
  // Load playlists from SharedPreferences
  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString('playlists') ?? '[]';
    
    final List<dynamic> playlistsData = json.decode(playlistsJson);
    _playlists = playlistsData.map((data) => Playlist.fromJson(data)).toList();
    
    // Create "Liked Songs" playlist if it doesn't exist
    if (!_playlists.any((playlist) => playlist.id == 'liked_songs')) {
      _playlists.add(Playlist(
        id: 'liked_songs',
        name: 'Liked Songs',
        description: 'Your favorite songs',
        coverImagePath: 'assets/images/liked_songs.png',
        songIds: [],
        createdAt: DateTime.now(),
      ));
      
      _savePlaylists();
    }
    
    notifyListeners();
  }
  
  // Save playlists to SharedPreferences
  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString('playlists', playlistsJson);
  }
  
  // Create a new playlist
  Future<void> createPlaylist(String name, {String? description}) async {
    final newPlaylist = Playlist(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      songIds: [],
      createdAt: DateTime.now(),
    );
    
    _playlists.add(newPlaylist);
    await _savePlaylists();
    notifyListeners();
  }
  
  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    // Don't allow deleting the "Liked Songs" playlist
    if (playlistId == 'liked_songs') return;
    
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    await _savePlaylists();
    notifyListeners();
  }
  
  // Get a playlist by ID
  Playlist? getPlaylist(String playlistId) {
    try {
      return _playlists.firstWhere((playlist) => playlist.id == playlistId);
    } catch (e) {
      return null;
    }
  }
  
  // Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index < 0) return;
    
    _playlists[index] = _playlists[index].addSong(songId);
    await _savePlaylists();
    notifyListeners();
  }
  
  // Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index < 0) return;
    
    _playlists[index] = _playlists[index].removeSong(songId);
    await _savePlaylists();
    notifyListeners();
  }
  
  // Update the "Liked Songs" playlist based on user data
  Future<void> syncLikedSongs(List<String> likedSongIds) async {
    final likedPlaylistIndex = _playlists.indexWhere((p) => p.id == 'liked_songs');
    if (likedPlaylistIndex < 0) return;
    
    final updatedPlaylist = Playlist(
      id: 'liked_songs',
      name: 'Liked Songs',
      description: 'Your favorite songs',
      coverImagePath: _playlists[likedPlaylistIndex].coverImagePath,
      songIds: likedSongIds,
      createdAt: _playlists[likedPlaylistIndex].createdAt,
    );
    
    _playlists[likedPlaylistIndex] = updatedPlaylist;
    await _savePlaylists();
    notifyListeners();
  }
  
  // Rename a playlist
  Future<void> renamePlaylist(String playlistId, String newName, {String? newDescription}) async {
    // Don't allow renaming the "Liked Songs" playlist
    if (playlistId == 'liked_songs') return;
    
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index < 0) return;
    
    final updatedPlaylist = Playlist(
      id: _playlists[index].id,
      name: newName,
      description: newDescription ?? _playlists[index].description,
      coverImagePath: _playlists[index].coverImagePath,
      songIds: _playlists[index].songIds,
      createdAt: _playlists[index].createdAt,
    );
    
    _playlists[index] = updatedPlaylist;
    await _savePlaylists();
    notifyListeners();
  }
}
