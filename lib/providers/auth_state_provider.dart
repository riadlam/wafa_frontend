import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

final _log = Logger('AuthStateProvider');

class AuthStateProvider with ChangeNotifier {
  bool _mounted = true;
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;
  
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  
  AuthStateProvider(this._authService) {
    _init();
  }
  
  void _init() {
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        _isLoggedIn = user != null;
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
      },
    );
    
    // Initial check
    checkAuthState();
  }

  /// Checks the current authentication state
  Future<void> checkAuthState() async {
    if (!_isLoading) {
      _setLoading(true);
    }
    
    try {
      _log.info('🔍 Checking auth state...');
      final isLoggedIn = await _authService.isLoggedIn();
      _log.info('🔑 Auth state check complete. isLoggedIn: $isLoggedIn');
      
      // Update state and notify listeners
      _isLoggedIn = isLoggedIn;
      _error = null;
      _log.info('🔄 Notifying listeners of auth state change');
      notifyListeners();
      
      // Add a small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));
      
    } catch (e, stackTrace) {
      _log.severe('Error checking auth state', e, stackTrace);
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _log.info('🔒 Starting sign out process');
      
      // Clear location data from SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_latitude');
        await prefs.remove('user_longitude');
        _log.info('✅ Cleared location data from SharedPreferences');
      } catch (e) {
        _log.warning('⚠️ Failed to clear location data', e);
        // Don't fail sign out if clearing location fails
      }
      
      // Sign out from auth service
      await _authService.signOut();
      
      // Update state in a single operation
      _isLoggedIn = false;
      _error = null;
      
      _log.info('✅ Successfully signed out');
      
      // Notify listeners once after all state changes
      if (_mounted) {
        notifyListeners();
      }
      
    } catch (e, stackTrace) {
      _log.severe('❌ Error during sign out', e, stackTrace);
      _error = e.toString();
      if (_mounted) {
        notifyListeners();
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  @override
  void dispose() {
    _mounted = false;
    _authSubscription?.cancel();
    _authSubscription = null;
    super.dispose();
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
