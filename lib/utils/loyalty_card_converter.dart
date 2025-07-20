import 'package:flutter/material.dart';
import 'package:loyaltyapp/models/loyalty_card_model.dart' as app_model;
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart' as ui_model;
import 'package:logger/logger.dart';

final _logger = Logger();

class LoyaltyCardConverter {
  static ui_model.LoyaltyCardModel toUiModel(app_model.LoyaltyCard card) {
    _logger.i('Converting loyalty card to UI model. Card ID: ${card.id}');
    _logger.d('Card data: ${{
      'id': card.id,
      'shopId': card.shopId,
      'logo': card.logo,
      'totalStamps': card.totalStamps,
      'activeStamps': card.activeStamps,
      'isSubscribed': card.isSubscribed,
    }}');

    // Convert hex color string to Color
    Color parseColor(String hexColor) {
      try {
        _logger.d('Parsing color: $hexColor');
        if (hexColor.isEmpty) return const Color(0xFFFF8C42);
        
        final buffer = StringBuffer();
        String hex = hexColor.replaceFirst('#', '').trim();
        
        if (hex.length == 6 || hex.length == 3) {
          buffer.write('ff'); // Add full opacity
          buffer.write(hex);
          final color = Color(int.parse(buffer.toString(), radix: 16));
          _logger.d('Parsed color (RGB): ${color.red},${color.green},${color.blue}');
          return color;
        } else if (hex.length == 8) {
          // Handle ARGB format
          final color = Color(int.parse(hex, radix: 16));
          _logger.d('Parsed color (ARGB): ${color.alpha},${color.red},${color.green},${color.blue}');
          return color;
        }
      } catch (e, stackTrace) {
        _logger.e('Error parsing color $hexColor', error: e, stackTrace: stackTrace);
      }
      return const Color(0xFFFF8C42); // Default color if parsing fails
    }

    // Process logo URL
    String? processLogoUrl(String? logo) {
      _logger.d('Processing logo URL: $logo');
      if (logo == null || logo.isEmpty) {
        _logger.w('Logo URL is null or empty');
        return null;
      }
      
      // Clean up the logo URL
      final cleanedLogo = logo.replaceAll('"', '').trim();
      
      // If it's already a full URL, return as is
      if (cleanedLogo.startsWith('http')) {
        _logger.d('Logo is already a full URL: $cleanedLogo');
        return cleanedLogo;
      }
      
      // For local paths, you might want to handle them differently
      if (cleanedLogo.startsWith('assets/')) {
        _logger.d('Logo is a local asset: $cleanedLogo');
        return cleanedLogo;
      }
      
      // If it's a relative path, construct full URL
      // Using the same base URL as in ApiClient for consistency
      final baseUrl = 'http://192.168.1.15:8000';
      final fullUrl = '$baseUrl${cleanedLogo.startsWith('/') ? '' : '/'}$cleanedLogo';
      _logger.d('Constructed full logo URL: $fullUrl');
      return fullUrl;
    }
    
    try {
      final logoUrl = processLogoUrl(card.logo);
      final earnedStamps = card.activeStamps ?? 0;
      
      _logger.d('Creating UI model with:');
      _logger.d('- Logo URL: $logoUrl');
      _logger.d('- Earned stamps: $earnedStamps');
      _logger.d('- Total stamps: ${card.totalStamps}');
      _logger.d('- Background color: ${card.backgroundColor}');
      _logger.d('- Secondary color: ${card.secondaryColor}');
      _logger.d('- Is subscribed: ${card.isSubscribed}');
      
      final uiModel = ui_model.LoyaltyCardModel(
        id: card.id.toString(),
        name: 'Loyalty Card',
        description: 'Earn stamps with your purchases',
        totalStamps: card.totalStamps,
        earnedStamps: earnedStamps,
        imageUrl: logoUrl,
        backgroundColor: parseColor(card.backgroundColor),
        secondaryColor: card.secondaryColor != null ? parseColor(card.secondaryColor!) : null,
        isSubscribed: card.isSubscribed ?? false,
      );
      
      _logger.i('Successfully created UI model for card ${card.id}');
      return uiModel;
    } catch (e, stackTrace) {
      _logger.e('Error creating UI model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
