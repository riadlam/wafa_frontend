import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Custom exception for auth errors
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {this.code = 'unknown'});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class AuthService {
  // Keys for storage
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhotoKey = 'user_photo';
  static const String _userRoleKey = 'user_role';
  
  // Firebase Auth instance
  final FirebaseAuth _auth;
  
  // Google Sign-In instance
  GoogleSignIn _googleSignIn;
  
  // Auth state stream controller
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get onAuthStateChanged => _authStateController.stream;
  
  // Secure storage for tokens
  final FlutterSecureStorage _storage;
  
  // SharedPreferences for non-sensitive user data
  SharedPreferences? _prefs;
  
  // Logger instance
  final Logger _logger = Logger();
  
  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user getter
  User? get currentUser => _auth.currentUser;
  
  // JWT token storage key
  static const String _jwtTokenKey = 'jwt_token';
  
  // Singleton pattern with lazy initialization
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  // Private constructor for the singleton pattern
  AuthService._internal() : 
    _auth = FirebaseAuth.instance,
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    ),
    _storage = const FlutterSecureStorage();
    
  // Named constructor for testing with dependency injection
  AuthService.forTesting({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         scopes: ['email', 'profile'],
       ),
       _storage = storage ?? const FlutterSecureStorage();

  // Get SharedPreferences instance
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Initialize the service
  Future<void> init() async {
    try {
      await prefs; // Initialize prefs
      if (kDebugMode) {
        developer.log('🔑 AuthService initialized');
      }
      
      // Single listener for auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          // User is signed in
          try {
            // Save user info
            await _saveUserInfo(
              email: user.email ?? '',
              name: user.displayName ?? '',
              photoUrl: user.photoURL ?? '',
            );
            
            // Get and store the ID token
            final token = await user.getIdToken();
            if (token != null) {
              await _storage.write(key: _tokenKey, value: token);
            }
            
            // Update auth state after all operations complete
            _authStateController.add(true);
            
            if (kDebugMode) {
              developer.log('✅ User signed in: ${user.email}');
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              developer.log('❌ Error processing auth state change', 
                          error: e, stackTrace: stackTrace);
            }
          }
        } else {
          // User is signed out
          try {
            await _clearUserData();
            _authStateController.add(false);
            
            if (kDebugMode) {
              developer.log('✅ User signed out');
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              developer.log('❌ Error during sign out', 
                          error: e, stackTrace: stackTrace);
            }
          }
        }
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('Error initializing AuthService', error: e, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      // Check Firebase Auth first
      if (_auth.currentUser != null) {
        return true;
      }
      
      // Fallback to token check
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error checking login status: $e');
      }
      return false;
    }
  }

  // Exchange Firebase token for JWT token from Laravel backend
  Future<String> _exchangeToken(String firebaseToken) async {
    try {
      _logger.i('Exchanging Firebase token for JWT token');
      
      final response = await http.post(
        Uri.parse('http://192.168.1.8:8000/api/login/firebase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': firebaseToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check for token in the response
        final jwtToken = responseData['access_token'] ?? responseData['token'];
        
        if (jwtToken == null) {
          throw AuthException('No token received from server', code: 'no_token');
        }
        
        // Store the JWT token securely
        await _storage.write(key: _jwtTokenKey, value: jwtToken);
        return jwtToken;
      } else {
        dynamic errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {
          errorData = {'message': response.body};
        }
        throw AuthException(
          errorData['message'] ?? 'Failed to authenticate with server',
          code: 'server_error',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Token exchange failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get the stored JWT token
  Future<String?> getJwtToken() async {
    try {
      if (kDebugMode) {
        developer.log('🔑 Retrieving JWT token from secure storage');
      }
      
      final token = await _storage.read(key: _jwtTokenKey);
      
      if (kDebugMode) {
        if (token != null) {
          developer.log('✅ JWT token retrieved successfully');
          developer.log('   Token length: ${token.length}');
          developer.log('   Token prefix: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');
        } else {
          developer.log('⚠️ No JWT token found in secure storage');
        }
      }
      
      return token;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Error retrieving JWT token', error: e, stackTrace: stackTrace);
      }
      return null;
    }
  }

  // Mark user as existed in the backend
  Future<bool> markUserAsExisted() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        throw AuthException('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.8:8000/api/mark-as-existed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message'] == 'User marked as existed successfully';
      } else {
        throw AuthException('Failed to mark user as existed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error marking user as existed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        _logger.i('🔵 Step 1: Starting Google Sign In flow');
      }

      // Sign out first to ensure a clean state
      if (kDebugMode) {
        _logger.i('🔵 Step 2: Signing out from any existing sessions');
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Trigger the Google Sign In flow with required scopes
      if (kDebugMode) {
        _logger.i('🔵 Step 3: Triggering Google Sign In UI');
      }
      
      // Use signIn() without parameters to use the default account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google Sign In was cancelled', code: 'sign_in_cancelled');
      }

      if (kDebugMode) {
        _logger.i('🔵 Step 4: Obtaining Google authentication details');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw AuthException('Failed to obtain tokens from Google', code: 'no_tokens');
      }
      
      if (kDebugMode) {
        _logger.i('🔵 Step 5: Creating Firebase credential');
      }
      
      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw AuthException('Failed to sign in with Google', code: 'sign_in_failed');
      }

      // 4. Exchange Firebase token for JWT
      final idToken = await user.getIdToken();
      final jwtToken = await _exchangeToken(idToken!);
      
      final userEmail = user.email;
      if (userEmail == null || userEmail.isEmpty) {
        throw AuthException('User email is required', code: 'missing_email');
      }
      
      // 5. Get user info from backend (including role)
      final userInfo = await _getUserInfoFromBackend(jwtToken);
      final userRole = userInfo['role'] as String? ?? 'user';
      
      // 6. Save all user info in a single operation
      await _saveUserInfo(
        email: userInfo['email'] as String? ?? userEmail,
        name: userInfo['name'] as String? ?? user.displayName ?? 'User',
        photoUrl: userInfo['avatar'] as String? ?? user.photoURL ?? '',
        role: userRole,
      );
      
      if (kDebugMode) {
        developer.log('✅ Google Sign In successful');
        developer.log('   UID: ${user.uid}');
        developer.log('   Email: $userEmail');
        developer.log('   Role: $userRole');
      }
      
      // 7. Update auth state
      _authStateController.add(true);
      
      // 8. Return user data
      return {
        'uid': user.uid,
        'email': userEmail,
        'name': user.displayName ?? 'User',
        'photoUrl': user.photoURL ?? '',
        'emailVerified': user.emailVerified,
        'jwt_token': jwtToken,
        'role': userRole,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Google sign in error', error: e, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  // Get the stored auth token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (kDebugMode) {
        if (token != null) {
          developer.log('🔑 Retrieved auth token from secure storage');
        } else {
          developer.log('ℹ️ No auth token found in secure storage');
        }
      }
      return token;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Error retrieving auth token', error: e, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  // Save user info to SharedPreferences
  Future<void> _saveUserInfo({
    required String email,
    required String name,
    required String photoUrl,
    String role = 'user', // Default role is 'user'
  }) async {
    try {
      final prefs = await this.prefs;
      
      // Save all data in a single batch
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userPhotoKey, photoUrl);
      await prefs.setString(_userRoleKey, role);
      
      if (kDebugMode) {
        // Single log statement with all user info
        developer.log('''
💾 Saved user info to SharedPreferences:
   Email: $email
   Name: $name
   Role: $role
   Photo URL: ${photoUrl.isNotEmpty ? '${photoUrl.substring(0, 20)}...' : 'Not set'}'
        ''');
      }
      
      // Notify listeners of the auth state change
      _authStateController.add(true);
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Error saving user info', 
                    error: e, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  // Get user email
  Future<String?> get userEmail async {
    final prefs = await this.prefs;
    return prefs.getString(_userEmailKey);
  }
  
  // Get user name
  Future<String?> get userName async {
    final prefs = await this.prefs;
    return prefs.getString(_userNameKey);
  }
  
  // Get user photo URL
  Future<String?> get userPhotoUrl async {
    final prefs = await this.prefs;
    return prefs.getString(_userPhotoKey);
  }
  
  // Get user role
  Future<String?> get userRole async {
    final prefs = await this.prefs;
    final role = prefs.getString(_userRoleKey);
    
    if (kDebugMode) {
      if (role != null) {
        developer.log('🔑 Retrieved user role: $role');
      } else {
        developer.log('⚠️ No user role found in SharedPreferences');
      }
    }
    
    return role;
  }
  
  // Get the current user's authentication state
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Sign out the current user
  Future<void> signOut() async {
    if (kDebugMode) {
      developer.log('🔒 Starting sign out process');
    }

    try {
      // 1. Sign out from Google first
      try {
        await _googleSignIn.signOut();
        if (kDebugMode) {
          developer.log('✅ Signed out from Google');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          developer.log('⚠️ Error signing out from Google', 
                      error: e, stackTrace: stackTrace);
        }
      }

      // 2. Sign out from Firebase
      // This will trigger the auth state change listener
      try {
        await _auth.signOut();
        if (kDebugMode) {
          developer.log('✅ Signed out from Firebase');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          developer.log('⚠️ Error signing out from Firebase', 
                      error: e, stackTrace: stackTrace);
        }
        // Even if there's an error, we should still try to clear local data
        await _clearUserData();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Error during sign out', 
                    error: e, stackTrace: stackTrace);
      }
      rethrow;
    }
  }
  
  // Get user info from backend using JWT token
  Future<Map<String, dynamic>> _getUserInfoFromBackend(String token) async {
    try {
      if (kDebugMode) {
        developer.log('🔍 Fetching user info from backend...');
      }
      
      final response = await http.get(
        Uri.parse('http://192.168.1.8:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'] ?? responseData; // Handle both nested and flat response
        
        if (kDebugMode) {
          developer.log('✅ Successfully fetched user info');
          developer.log('   Full response: $responseData');
          developer.log('   User data: $userData');
          
          if (userData['role'] != null) {
            developer.log('   User role from backend: ${userData['role']}');
          } else {
            developer.log('⚠️ No role found in user data, defaulting to "user"');
          }
        }
        
        // Return the user data with the role
        return {
          'email': userData['email'],
          'name': userData['name'],
          'role': userData['role'] ?? 'user', // Ensure role has a default value
          'avatar': userData['avatar'],
          'id': userData['id'],
          // Add other user fields as needed
        };
      } else {
        final errorMsg = 'Failed to fetch user info: ${response.statusCode} - ${response.body}';
        if (kDebugMode) {
          developer.log('❌ $errorMsg');
        }
        throw AuthException(errorMsg, code: 'user_info_fetch_failed');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching user info', error: e, stackTrace: stackTrace);
      return {'role': 'user'};
    }
  }

  // Clear all user data from storage
  Future<void> _clearUserData() async {
    try {
      if (kDebugMode) {
        developer.log('🧹 Clearing all user data');
        // Log role before clearing
        final currentRole = await userRole;
        developer.log('   Current role before clearing: ${currentRole ?? 'none'}');
      }
      
      // Clear secure storage
      await _storage.deleteAll();
      
      // Clear SharedPreferences
      final prefs = await this.prefs;
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userPhotoKey);
      await prefs.remove(_userRoleKey);
      _authStateController.add(false);
      try {
        // Add any in-memory cache clearing logic here
        if (kDebugMode) {
          developer.log('✅ Cleared in-memory caches');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          developer.log('⚠️ Error clearing in-memory caches', 
                      error: e, stackTrace: stackTrace);
        }
      }
      
      if (kDebugMode) {
        developer.log('✅ Successfully cleared all user data');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Critical error during user data clearance', 
                    error: e, stackTrace: stackTrace);
      }
      // Re-throw to ensure the sign-out process is aware of the failure
      rethrow;
    }
  }


  

}

// Singleton instance
final authService = AuthService()..init();
