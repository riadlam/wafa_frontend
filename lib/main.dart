import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/providers/auth_state_provider.dart';
import 'package:loyaltyapp/providers/user_provider.dart';
import 'package:loyaltyapp/providers/loyalty_card_provider.dart';
import 'package:loyaltyapp/providers/websocket_provider.dart';
import 'package:loyaltyapp/router/app_router.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'package:loyaltyapp/hive_models/hive_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      developer.log('✅ Firebase initialized successfully');
    }
    
    // Initialize Hive
    await HiveService.ensureInitialized();
    if (kDebugMode) {
      developer.log('✅ Hive initialized successfully');
    }
    
    // Create an instance of AuthService
    final authService = AuthService();
    
    // Initialize AuthService
    await authService.init();
    
    // Create providers
    final userProvider = UserProvider();
    final loyaltyCardProvider = LoyaltyCardProvider();
    
    // Load saved language preference
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    
    // Initialize EasyLocalization with saved language
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
          Locale('ar'),
        ],
        path: 'assets/l10n', // Path to translation files
        fallbackLocale: const Locale('en', ''), // Fallback locale
        startLocale: Locale(savedLanguageCode), // Default locale
        child: MultiProvider(
          providers: [
            // Provide AuthService instance
            Provider<AuthService>.value(
              value: authService,
            ),
            // Auth state provider
            ChangeNotifierProvider(
              create: (_) => AuthStateProvider(authService),
              lazy: false, // Initialize immediately
            ),
            // User provider
            ChangeNotifierProvider<UserProvider>(
              create: (_) => userProvider,
              lazy: false, // Initialize immediately
            ),
            // Loyalty card provider
            ChangeNotifierProvider<LoyaltyCardProvider>(
              create: (_) => loyaltyCardProvider,
              lazy: false, // Initialize immediately
            ),
            // WebSocket provider
            ChangeNotifierProvider<WebSocketProvider>(
              create: (_) => WebSocketProvider(),
              lazy: false, // Initialize immediately
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
    
    // Initialize providers after the app is running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.initialize();
      // Initialize loyalty card provider when user is logged in
      if (authService.currentUser != null) {
        loyaltyCardProvider.fetchCardData();
      }
    });
    
  } catch (e, stackTrace) {
    if (kDebugMode) {
      developer.log('❌ Error initializing app', error: e, stackTrace: stackTrace);
    }
    // Run app anyway with error handling
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app. Please restart.'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      developer.log('🏗️ Building MyApp');
    }
    
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'appTitle'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primary80,
          secondary: AppColors.grey,
          secondaryContainer: AppColors.lightGrey,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.black,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
          onError: AppColors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF5003),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF5003), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5003),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
