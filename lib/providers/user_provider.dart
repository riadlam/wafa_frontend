import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:loyaltyapp/models/user_model.dart';
import 'package:loyaltyapp/services/api_client.dart';
import 'package:loyaltyapp/services/auth_service.dart';

const String _logTag = 'UserProvider';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  StreamSubscription<bool>? _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  
  UserProvider() {
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    _authSubscription = _authService.onAuthStateChanged.listen((isLoggedIn) async {
      if (isLoggedIn) {
        await fetchUser();
      } else {
        clearUser();
      }
    });
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    developer.log('[$_logTag] Initializing UserProvider', name: _logTag);
    
    // Check if user is authenticated before fetching
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      _isInitialized = true;
      _isLoading = false;
      _user = null;
      notifyListeners();
      return;
    }
    
    await fetchUser();
  }

  Future<bool> fetchUser() async {
    if (!await _authService.isAuthenticated()) {
      developer.log('[$_logTag] Not authenticated, skipping user fetch', name: _logTag);
      _user = null;
      _error = null;
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      return false;
    }

    developer.log('[$_logTag] Starting to fetch user data', name: _logTag);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('[$_logTag] Making API call to /user', name: _logTag);
      final response = await _apiClient.get('/user');
      developer.log('[$_logTag] API response: $response', name: _logTag);
      
      if (response != null && response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        _error = null;
        developer.log('[$_logTag] User data loaded successfully', name: _logTag);
      } else {
        developer.log('[$_logTag] No user data in response', name: _logTag);
        _user = null;
        _error = 'No user data available';
      }
      return true;
    } catch (e, stackTrace) {
      developer.log('[$_logTag] Error fetching user', 
                   name: _logTag, 
                   error: e, 
                   stackTrace: stackTrace);
      _user = null;
      _error = e is Exception ? e.toString() : 'An unknown error occurred';
      return false;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      developer.log('[$_logTag] Fetch user completed. Loading: $_isLoading, Has user: ${_user != null}', 
                   name: _logTag);
    }
  }

  void updateUser(UserModel user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
