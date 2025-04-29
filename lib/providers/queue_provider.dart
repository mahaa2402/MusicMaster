import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_music_stream/models/song.dart';

class QueueProvider with ChangeNotifier {
  List<String> _queue = []; // List of song IDs in the queue
  int _currentIndex = -1;
  
  List<String> get queue => _queue;
  int get currentIndex => _currentIndex;
  
  QueueProvider() {
    _loadQueue();
  }
  
  // Load queue from SharedPreferences
  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString('queue') ?? '[]';
    _queue = List<String>.from(json.decode(queueJson));
    _currentIndex = prefs.getInt('queueCurrentIndex') ?? -1;
    
    // Make sure currentIndex is valid
    if (_currentIndex >= _queue.length) {
      _currentIndex = _queue.isEmpty ? -1 : 0;
    }
    
    notifyListeners();
  }
  
  // Save queue to SharedPreferences
  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('queue', json.encode(_queue));
    await prefs.setInt('queueCurrentIndex', _currentIndex);
  }
  
  // Set a new queue (replaces current queue)
  Future<void> setQueue(List<String> songIds, {int startIndex = 0}) async {
    _queue = List<String>.from(songIds);
    _currentIndex = startIndex < _queue.length ? startIndex : 0;
    
    await _saveQueue();
    notifyListeners();
  }
  
  // Add a song to the queue
  Future<void> addToQueue(String songId) async {
    if (!_queue.contains(songId)) {
      _queue.add(songId);
      
      // If queue was empty, set current index to 0
      if (_queue.length == 1) {
        _currentIndex = 0;
      }
      
      await _saveQueue();
      notifyListeners();
    }
  }
  
  // Remove a song from the queue
  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;
    
    _queue.removeAt(index);
    
    // Adjust currentIndex if necessary
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _currentIndex >= _queue.length) {
      _currentIndex = _queue.isEmpty ? -1 : 0;
    }
    
    await _saveQueue();
    notifyListeners();
  }
  
  // Move a song in the queue
  Future<void> moveSongInQueue(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queue.length || 
        newIndex < 0 || newIndex >= _queue.length) {
      return;
    }
    
    final songId = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, songId);
    
    // Adjust currentIndex if necessary
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    
    await _saveQueue();
    notifyListeners();
  }
  
  // Get the ID of the current song in queue
  String? getCurrentSongId() {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _queue[_currentIndex];
    }
    return null;
  }
  
  // Move to the next song in queue
  String? getNextSongId() {
    if (_queue.isEmpty) return null;
    
    _currentIndex = (_currentIndex + 1) % _queue.length;
    _saveQueue();
    notifyListeners();
    
    return getCurrentSongId();
  }
  
  // Move to the previous song in queue
  String? getPreviousSongId() {
    if (_queue.isEmpty) return null;
    
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    _saveQueue();
    notifyListeners();
    
    return getCurrentSongId();
  }
  
  // Clear the queue
  Future<void> clearQueue() async {
    _queue = [];
    _currentIndex = -1;
    
    await _saveQueue();
    notifyListeners();
  }
  
  // Add a list of songs to queue
  Future<void> addMultipleToQueue(List<String> songIds) async {
    bool wasEmpty = _queue.isEmpty;
    
    for (final songId in songIds) {
      if (!_queue.contains(songId)) {
        _queue.add(songId);
      }
    }
    
    // If queue was empty, set current index to 0
    if (wasEmpty && _queue.isNotEmpty) {
      _currentIndex = 0;
    }
    
    await _saveQueue();
    notifyListeners();
  }
}
