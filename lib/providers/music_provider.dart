import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_music_stream/models/song.dart';

enum PlaybackState {
  playing,
  paused,
  stopped,
  loading,
}

enum RepeatMode {
  off,
  all,
  one,
}

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Song> _songs = [];
  Song? _currentSong;
  PlaybackState _playbackState = PlaybackState.stopped;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _isShuffleEnabled = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  PlaybackState get playbackState => _playbackState;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  Duration get position => _position;
  Duration get duration => _duration;
  
  MusicProvider() {
    _init();
  }
  
  Future<void> _init() async {
    // Load songs from JSON file
    await _loadSongs();
    
    // Load previous playback state if any
    await _loadPlaybackState();
    
    // Setup audio player listeners
    _setupAudioPlayerListeners();
  }
  
  void _setupAudioPlayerListeners() {
    // Position updates
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    
    // Duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });
    
    // Playback state updates
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _playbackState = PlaybackState.playing;
      } else if (playerState.processingState == ProcessingState.loading) {
        _playbackState = PlaybackState.loading;
      } else if (playerState.processingState == ProcessingState.completed) {
        // When song completes
        if (_repeatMode == RepeatMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          playNext();
        }
      } else {
        _playbackState = PlaybackState.paused;
      }
      notifyListeners();
    });
  }
  
  Future<void> _loadSongs() async {
    try {
      // Load songs from the assets
      final String jsonString = await rootBundle.loadString('assets/data/songs.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _songs = jsonList.map((json) => Song.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading songs: $e');
      _songs = [];
    }
  }
  
  Future<void> _loadPlaybackState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get last played song ID
    final lastSongId = prefs.getString('lastSongId');
    if (lastSongId != null && _songs.isNotEmpty) {
      final song = _songs.firstWhere(
        (song) => song.id == lastSongId,
        orElse: () => _songs.first,
      );
      
      // Set as current song but don't play automatically
      _currentSong = song;
      
      // Load the audio
      await _audioPlayer.setAsset(song.assetPath);
      
      // Restore position
      final position = prefs.getInt('lastPosition') ?? 0;
      if (position > 0) {
        await _audioPlayer.seek(Duration(milliseconds: position));
      }
    }
    
    // Restore settings
    _repeatMode = RepeatMode.values[prefs.getInt('repeatMode') ?? 0];
    _isShuffleEnabled = prefs.getBool('isShuffleEnabled') ?? false;
    
    notifyListeners();
  }
  
  Future<void> _savePlaybackState() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_currentSong != null) {
      await prefs.setString('lastSongId', _currentSong!.id);
      await prefs.setInt('lastPosition', _position.inMilliseconds);
    }
    
    await prefs.setInt('repeatMode', _repeatMode.index);
    await prefs.setBool('isShuffleEnabled', _isShuffleEnabled);
  }
  
  // Play a specific song
  Future<void> playSong(Song song) async {
    if (_currentSong?.id == song.id && _playbackState == PlaybackState.paused) {
      // If the same song is paused, just resume
      return play();
    }
    
    _currentSong = song;
    
    // Load and play the song
    await _audioPlayer.stop();
    await _audioPlayer.setAsset(song.assetPath);
    await _audioPlayer.play();
    
    _savePlaybackState();
    notifyListeners();
  }
  
  // Play or resume current song
  Future<void> play() async {
    if (_currentSong == null && _songs.isNotEmpty) {
      return playSong(_songs.first);
    }
    
    await _audioPlayer.play();
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }
  
  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    _playbackState = PlaybackState.paused;
    _savePlaybackState();
    notifyListeners();
  }
  
  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    _position = position;
    notifyListeners();
  }
  
  // Play next song (considering shuffle and repeat)
  Future<void> playNext() async {
    if (_songs.isEmpty || _currentSong == null) return;
    
    int currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex == -1) return;
    
    int nextIndex;
    
    if (_isShuffleEnabled) {
      // Play random song (except current)
      nextIndex = _getRandomIndex(excluding: currentIndex);
    } else {
      // Play next song in list
      nextIndex = (currentIndex + 1) % _songs.length;
    }
    
    // If we're at the end and repeat is off, just stop
    if (nextIndex <= currentIndex && _repeatMode == RepeatMode.off) {
      await _audioPlayer.stop();
      _playbackState = PlaybackState.stopped;
      notifyListeners();
      return;
    }
    
    await playSong(_songs[nextIndex]);
  }
  
  // Play previous song
  Future<void> playPrevious() async {
    if (_songs.isEmpty || _currentSong == null) return;
    
    // If we're more than 3 seconds into the song, restart it
    if (_position.inSeconds > 3) {
      return seekTo(Duration.zero);
    }
    
    int currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex == -1) return;
    
    int prevIndex;
    
    if (_isShuffleEnabled) {
      // Play random song (except current)
      prevIndex = _getRandomIndex(excluding: currentIndex);
    } else {
      // Play previous song in list (or last if at beginning)
      prevIndex = (currentIndex - 1 + _songs.length) % _songs.length;
    }
    
    await playSong(_songs[prevIndex]);
  }
  
  // Toggle shuffle mode
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _savePlaybackState();
    notifyListeners();
  }
  
  // Change repeat mode
  void changeRepeatMode() {
    _repeatMode = RepeatMode.values[(_repeatMode.index + 1) % RepeatMode.values.length];
    _savePlaybackState();
    notifyListeners();
  }
  
  // Get a random index for shuffle mode
  int _getRandomIndex({required int excluding}) {
    if (_songs.length <= 1) return 0;
    
    // Generate a random index that's not the current one
    int randomIndex;
    do {
      randomIndex = (DateTime.now().millisecondsSinceEpoch % _songs.length).floor();
    } while (randomIndex == excluding);
    
    return randomIndex;
  }
  
  // Search songs by title or artist
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _songs;
    
    final lowercaseQuery = query.toLowerCase();
    return _songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) || 
             song.artist.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  // Cleanup
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
