import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/providers/user_provider.dart';
import 'package:loyaltyapp/services/auth_service.dart' show AuthService, AuthException;
import 'package:loyaltyapp/constants/routes.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access the context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }
  
  Future<void> _initializeAuth() async {
    if (!mounted) return;
    
    try {
      // Get the AuthService instance using Provider
      final authService = context.read<AuthService>();
      
      // Initialize auth service if needed
      await authService.init();
      
      // Check if already logged in
      final isLoggedIn = await authService.isLoggedIn();
      if (isLoggedIn && mounted) {
        if (kDebugMode) {
          developer.log('✅ User already logged in, navigating to home');
        }
        _navigateToHome();
        return;
      }
      
      // Set initialized to true to show the UI
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Error initializing auth', error: e, stackTrace: stackTrace);
      }
      // Still set initialized to true to show the UI with error state
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }
  
  void _navigateToHome() {
    if (mounted) {
      // Navigate to user type selection screen after login
      context.go(Routes.userTypeSelection);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    
    if (_isLoading) return;
    
    if (kDebugMode) {
      developer.log('🔄 Starting Google sign in process...');
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      
      if (kDebugMode) {
        developer.log('🔵 Step 1: Calling signInWithGoogle()');
      }
      
      // Sign in with Google
      final userData = await authService.signInWithGoogle();
      
      if (kDebugMode) {
        developer.log('✅ Google sign in successful');
        developer.log('   User data: ${userData.toString()}');
      }
      
      // Verify we have a JWT token
      final jwtToken = userData['jwt_token'];
      if (jwtToken == null) {
        throw Exception('No JWT token received from server');
      }
      
      if (kDebugMode) {
        developer.log('🔑 JWT token received and stored successfully');
      }
      
      // Check if user exists and navigate accordingly
      if (mounted) {
        // Add a small delay to ensure the UI updates properly
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.fetchUser();
          
          if (context.mounted) {
            final user = userProvider.user;
            if (user != null) {
              // Check user role first
              if (user.role == 'shop_owner') {
                if (kDebugMode) {
                  developer.log('👔 Shop owner detected, navigating to admin dashboard');
                }
                context.go(Routes.adminDashboard);
              } 
              // Then check if user exists (is_existed = 1) or is new (is_existed = 0)
              else if (user.isExisted == 1) {
                // Existing user - go to home
                if (kDebugMode) {
                  developer.log('👤 Existing user, navigating to home');
                }
                context.go(Routes.home);
              } else {
                // New user - go to user type selection
                if (kDebugMode) {
                  developer.log('👤 New user, navigating to user type selection');
                }
                context.go(Routes.userTypeSelection);
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('❌ Google sign in failed', error: e, stackTrace: stackTrace);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AuthException 
                ? e.message 
                : e.toString().contains('sign_in_canceled')
                    ? 'Sign in canceled'
                    : 'Failed to sign in with Google. Please try again.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and welcome text
                Column(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Fidelity App',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                'https://www.google.com/favicon.ico',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.g_mobiledata, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with 'or' in the middle
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 24),

                // Email/Password Form
                // ... (email/password form fields would go here)


                const SizedBox(height: 32),

                // Terms and Privacy Policy
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
