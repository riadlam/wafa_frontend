import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/providers/auth_state_provider.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'package:loyaltyapp/constants/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Delay the auth check slightly to ensure the UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    debugPrint('🔄 Starting auth check...');
    try {
      final authState = Provider.of<AuthStateProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      debugPrint('🔍 Checking auth state...');
      
      // Wait for the auth state to be determined
      await authState.checkAuthState();
      
      // Wait for the auth state to be updated
      await Future.delayed(const Duration(milliseconds: 300));
      
      debugPrint('✅ Auth check completed');
      
      // Use GoRouter for navigation
      if (!mounted) return;
      
      final router = GoRouter.of(context);
      if (authState.isLoggedIn) {
        // Get the user role
        final role = await authService.userRole;
        debugPrint('👤 User role: $role');
        
        // Navigate based on role
        if (role == 'shop_owner') {
          debugPrint('🏪 User is a shop owner, navigating to admin dashboard');
          router.go(Routes.adminDashboard);
        } else {
          debugPrint('🏠 User is a regular user, navigating to home');
          router.go(Routes.home);
        }
      } else {
        debugPrint('🔒 User is not logged in, navigating to login');
        router.go(Routes.login);
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error checking auth state: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // If there's an error, navigate to login screen after a short delay
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          debugPrint('⚠️ Error occurred, navigating to login');
          GoRouter.of(context).go('/login');
        }
      }
    } finally {
      if (mounted) {
        debugPrint('🏁 Auth check finished, updating UI');
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/name placeholder
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.loyalty,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loyalty App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            if (_isCheckingAuth)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
