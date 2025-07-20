import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/routes.dart';
import '../providers/auth_state_provider.dart';

class LogoutService {
  static bool _isLoggingOut = false;

  static Future<void> logout(BuildContext context) async {
    // Prevent multiple simultaneous logout attempts
    if (_isLoggingOut) {
      developer.log('⚠️ [LogoutService] Logout already in progress');
      return;
    }

    _isLoggingOut = true;
    developer.log('🔑 [LogoutService] Starting logout process');

    try {
      final authState = Provider.of<AuthStateProvider>(context, listen: false);
      final router = GoRouter.of(context);
      
      // 1. First navigate to splash screen to prevent any UI glitches
      developer.log('🔄 [LogoutService] Navigating to splash screen first');
      router.go(Routes.splash, extra: 'logging_out');
      
      // 2. Then sign out (this will trigger a rebuild)
      developer.log('🔒 [LogoutService] Signing out user');
      await authState.signOut();
      
      developer.log('✅ [LogoutService] Logout process completed successfully');
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LogoutService] Error during logout',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Even if there's an error, ensure we're on the login screen
      if (context.mounted) {
        try {
          GoRouter.of(context).go(Routes.login);
        } catch (navError) {
          developer.log('❌ [LogoutService] Failed to navigate to login: $navError');
        }
      }
    } finally {
      _isLoggingOut = false;
    }
  }
}
