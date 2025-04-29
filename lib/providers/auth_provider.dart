import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_music_stream/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (userJson != null && isLoggedIn) {
      _currentUser = User.fromJson(json.decode(userJson));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Register a new user
  Future<bool> register(String username, String email, String password) async {
    // In a real app, this would call an API
    // Here we just simulate user creation
    
    // Check if user already exists
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    List<dynamic> users = json.decode(usersJson);
    
    // Check if email is already registered
    final emailExists = users.any((user) => user['email'] == email);
    if (emailExists) {
      return false;
    }
    
    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      likedSongIds: [],
      recentlyPlayedIds: [],
    );
    
    // Save user credentials
    users.add({
      ...newUser.toJson(),
      'password': password, // In a real app, this would be hashed
    });
    
    await prefs.setString('users', json.encode(users));
    
    // Auto login after registration
    return login(email, password);
  }

  // Login user
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    List<dynamic> users = json.decode(usersJson);
    
    // Find user with matching email and password
    final userJson = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => null,
    );
    
    if (userJson == null) {
      return false;
    }
    
    // Create user object (exclude password)
    final userData = Map<String, dynamic>.from(userJson);
    userData.remove('password');
    _currentUser = User.fromJson(userData);
    
    // Set login state
    _isLoggedIn = true;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
    
    notifyListeners();
    return true;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isLoggedIn = false;
    _currentUser = null;
    
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUser');
    
    notifyListeners();
  }

  // Update user liked songs
  Future<void> toggleLikedSong(String songId) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.toggleLikedSong(songId);
    
    // Save updated user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
    
    // Also update in users list
    final usersJson = prefs.getString('users') ?? '[]';
    List<dynamic> users = json.decode(usersJson);
    
    final userIndex = users.indexWhere((user) => user['id'] == _currentUser!.id);
    if (userIndex >= 0) {
      // Preserve password
      final password = users[userIndex]['password'];
      users[userIndex] = {
        ..._currentUser!.toJson(),
        'password': password,
      };
      
      await prefs.setString('users', json.encode(users));
    }
    
    notifyListeners();
  }

  // Add song to recently played
  Future<void> addToRecentlyPlayed(String songId) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.addToRecentlyPlayed(songId);
    
    // Save updated user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
    
    // Also update in users list
    final usersJson = prefs.getString('users') ?? '[]';
    List<dynamic> users = json.decode(usersJson);
    
    final userIndex = users.indexWhere((user) => user['id'] == _currentUser!.id);
    if (userIndex >= 0) {
      // Preserve password
      final password = users[userIndex]['password'];
      users[userIndex] = {
        ..._currentUser!.toJson(),
        'password': password,
      };
      
      await prefs.setString('users', json.encode(users));
    }
    
    notifyListeners();
  }
}
