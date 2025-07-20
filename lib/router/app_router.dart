import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/admin/dashbored/dashbored_profile.dart';
import 'package:loyaltyapp/screens/search/search_screen.dart';
import 'package:loyaltyapp/screens/profile/profile_page.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/sbscribed_loyalty_cards.dart';
import 'package:provider/provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/user_type_selection_screen.dart';
import '../admin/data_filling/multiform_screen.dart';
import '../admin/dashbored/dashbored_home.dart';
import '../providers/auth_state_provider.dart';
import '../constants/routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Public routes
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Protected routes - only accessible when logged in
      GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: Routes.userTypeSelection,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const UserTypeSelectionScreen(),
        ),
      ),
      GoRoute(
        path: Routes.shopOwnerSetup,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MultiFormScreen(),
        ),
      ),
      GoRoute(
        path: Routes.adminDashboard,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DashboardHome(),
        ),
      ),
      // Nested route for search with persistent nav bar
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: HomeScreen(selectedTab: 1), // Show HomeScreen with search tab selected
        ),
      ),
      GoRoute(
        path: '/cards',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: HomeScreen(selectedTab: 2), // Show HomeScreen with cards tab selected
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: HomeScreen(selectedTab: 3), // Show HomeScreen with profile tab selected
        ),
      ),
     
      

    ],
    redirect: (BuildContext? context, GoRouterState state) {
      if (context == null) {
        debugPrint('⚠️ Router: No context available');
        return null;
      }
      
      final authState = context.read<AuthStateProvider>();
      final isLoggedIn = authState.isLoggedIn;
      final isLoginRoute = state.uri.path == Routes.login;
      final isSplashRoute = state.uri.path == Routes.splash;
      final isLoggingOut = state.extra == 'logging_out';

      debugPrint('''
🔄 Router State Update:
- Current route: ${state.uri.path}
- isLoggedIn: $isLoggedIn
- isLoading: ${authState.isLoading}
- isLoginRoute: $isLoginRoute
- isSplashRoute: $isSplashRoute
- isLoggingOut: $isLoggingOut
      ''');

      // If we're in the process of logging out, stay on splash
      if (isLoggingOut && isSplashRoute) {
        debugPrint('🔐 Router: Currently logging out, staying on splash screen');
        return null;
      }

      // If auth state is still loading, stay on current route
      if (authState.isLoading) {
        debugPrint('⏳ Router: Auth state still loading, waiting...');
        return null;
      }

      // If user is not logged in, redirect to login
      if (!isLoggedIn) {
        // Only redirect if we're not already on the login or splash route
        if (!isLoginRoute && !isSplashRoute) {
          debugPrint('🔒 Router: Not logged in, redirecting to login');
          return Routes.login;
        }
        return null;
      }

      // If we're on login/splash but already logged in, go to home
      if ((isSplashRoute || isLoginRoute) && isLoggedIn) {
        debugPrint('🏠 Router: Already logged in, redirecting to home');
        return Routes.home;
      }

      debugPrint('✅ Router: No redirect needed for ${state.uri.path}');
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// For backward compatibility
final appRouter = AppRouter.router;
