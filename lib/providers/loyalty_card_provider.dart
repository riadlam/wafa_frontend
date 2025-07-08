import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/services/loyalty_card_service.dart';

class LoyaltyCardProvider with ChangeNotifier {
  final LoyaltyCardService _loyaltyCardService = LoyaltyCardService();
  
  // Current card data
  String? _shopName;
  String? _description;
  int _totalStamps = 10; // Default value
  Color _cardColor = const Color(0xFF6C63FF); // Default color
  File? _logoImage;
  String? _logoUrl;
  bool _isLoading = false;
  
  // Getters
  String? get shopName => _shopName;
  String? get description => _description;
  int get totalStamps => _totalStamps;
  Color get cardColor => _cardColor;
  File? get logoImage => _logoImage;
  String? get logoUrl => _logoUrl;
  bool get isLoading => _isLoading;
  
  // Helper to convert hex string to Color
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }
    return const Color(0xFF6C63FF); // Default color
  }
  
  // Helper to convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
  
  // Fetch current card data
  Future<void> fetchCardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Fetching shop loyalty cards...');
      final shopCards = await _loyaltyCardService.getMyShopLoyaltyCards();
      debugPrint('Fetched ${shopCards.length} shop cards');
      
      if (shopCards.isNotEmpty) {
        debugPrint('First shop name: ${shopCards.first.name}');
        
        if (shopCards.first.loyaltyCards.isNotEmpty) {
          final card = shopCards.first.loyaltyCards.first;
          
          debugPrint('Card data:');
          debugPrint('- ID: ${card.id}');
          debugPrint('- Shop ID: ${card.shopId}');
          debugPrint('- Logo: ${card.logo}');
          debugPrint('- Color: ${card.backgroundColor}');
          debugPrint('- Total Stamps: ${card.totalStamps}');
          debugPrint('- Description: ${card.description}');
          
          _shopName = shopCards.first.name;
          _description = card.description ?? ''; // Ensure we don't set null
          _totalStamps = card.totalStamps;
          _cardColor = _hexToColor(card.backgroundColor);
          _logoUrl = card.logo;
          
          debugPrint('Updated provider with description: "$_description"');
        } else {
          debugPrint('No loyalty cards found in the shop');
          _description = ''; // Reset description if no cards found
        }
      } else {
        debugPrint('No shop data found');
        _description = ''; // Reset description if no shop data
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching card data: $e');
      debugPrint('Stack trace: $stackTrace');
      _description = ''; // Reset description on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update card data
  Future<bool> updateCardData({
    required String shopName,
    required String description,
    required int totalStamps,
    required Color cardColor,
    File? logoImage,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Updating card data with:');
      debugPrint('- Shop Name: $shopName');
      debugPrint('- Description: $description');
      debugPrint('- Total Stamps: $totalStamps');
      debugPrint('- Color: ${_colorToHex(cardColor)}');
      
      final response = await _loyaltyCardService.updateLoyaltyCard(
        cardId: 1, // You might want to make this dynamic
        shopName: shopName,
        description: description,
        color: _colorToHex(cardColor),
        totalStamps: totalStamps,
        logoFile: logoImage,
      );
      
      debugPrint('Update response: $response');
      
      // Update local state with new values
      _shopName = shopName;
      _description = description; // Update description from the parameter
      _totalStamps = totalStamps;
      _cardColor = cardColor;
      
      if (response['logo_url'] != null) {
        _logoUrl = response['logo_url'];
      }
      
      debugPrint('Successfully updated card data');
      debugPrint('New description in provider: $_description');
      
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error updating card data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update logo
  void updateLogo(File? image) {
    _logoImage = image;
    notifyListeners();
  }
  
  // Update color
  void updateColor(Color color) {
    _cardColor = color;
    notifyListeners();
  }
}
