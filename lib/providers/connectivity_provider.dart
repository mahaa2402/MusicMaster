import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  
  bool get isConnected => _isConnected;
  
  ConnectivityProvider() {
    _initConnectivity();
    _setupConnectivityListener();
  }
  
  // Initialize connectivity state
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Failed to get connectivity: $e');
      _isConnected = true; // Default to connected to ensure app functionality
    }
  }
  
  // Setup listener for connectivity changes
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _isConnected = false;
    } else {
      _isConnected = true;
    }
    notifyListeners();
  }
}
