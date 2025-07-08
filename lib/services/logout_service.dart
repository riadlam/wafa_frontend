import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import '../constants/routes.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    try {
      // Get the auth state provider
      final authState = Provider.of<AuthStateProvider>(
        context,
        listen: false,
      );

      // Sign out from the auth provider
      await authState.signOut();

      // Ensure the context is still valid
      if (!context.mounted) return;

      // Navigate to login screen without any back navigation
      final router = GoRouter.of(context);
      
      // Use pushReplacement to prevent going back to protected routes
      if (router.canPop()) {
        router.pop();
      }
      
      // Ensure we're at the root before navigating
      while (router.canPop()) {
        router.pop();
      }
      
      // Navigate to login screen
      router.go(Routes.login);
      
      // Force a small delay to ensure navigation completes
      await Future.delayed(const Duration(milliseconds: 100));
      
    } catch (e) {
      // Log the error
      debugPrint('Logout error: $e');
      
      // If there's an error, still try to navigate to login
      if (context.mounted) {
        final router = GoRouter.of(context);
        router.go(Routes.login);
      }
    }
  }
}
