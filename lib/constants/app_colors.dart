import 'package:flutter/material.dart';

class AppColors {
  // Primary orange color (Fidelity orange)
  static const Color primary = Color(0xFFFF5003);
  
  // Primary with opacity variations
  static const Color primary90 = Color(0xE6FF5003); // 90% opacity
  static const Color primary80 = Color(0xCCFF5003); // 80% opacity
  static const Color primary60 = Color(0x99FF5003); // 60% opacity
  static const Color primary40 = Color(0x66FF5003); // 40% opacity
  static const Color primary20 = Color(0x33FF5003); // 20% opacity
  static const Color primary10 = Color(0x1AFF5003); // 10% opacity
  
  // Background colors
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
  
  // Divider
  static const Color divider = Color(0xFFE0E0E0);
  
  // Disabled colors
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFEEEEEE);
  
  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7043), // Lighter orange
      Color(0xFFFF5003), // Primary orange
      Color(0xFFE64A19), // Darker orange
    ],
  );
}
