import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/providers/auth_state_provider.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
        try {
          // Get the JWT token
          final jwtToken = await authService.getJwtToken();
          if (jwtToken == null) {
            throw Exception('No JWT token found');
          }

          // Fetch user info from the API
          debugPrint('🔍 Fetching user info from API...');
          final userInfo = await authService.getUserInfoFromBackend(jwtToken);
          final role = userInfo['role']?.toString().toLowerCase() ?? 'user';
          debugPrint('👤 User role from API: $role');

          // Check registration phase first for all users
          final prefs = await SharedPreferences.getInstance();
          final isRegistrationPhase = prefs.getBool('registration_phase') ?? false;

          if (isRegistrationPhase) {
            debugPrint('🔄 User is in registration phase, navigating to shop owner setup');
            router.go(Routes.userTypeSelection);
            return;
          }

          // If not in registration phase, navigate based on role
          if (role == 'shop_owner') {
            debugPrint('🏪 User is a shop owner, navigating to admin dashboard');
            router.go(Routes.adminDashboard);
          } else {
            debugPrint('🏠 User is a regular user, navigating to home');
            router.go(Routes.home);
          }
        } catch (e) {
          debugPrint('❌ Error during role-based navigation: $e');
          // Fallback to home if there's an error
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
      backgroundColor: const Color(0xFFff691e),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Image.asset(
                'assets/images/full_logo.png',
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 40),
            if (_isCheckingAuth)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
