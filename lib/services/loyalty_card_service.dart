import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/models/loyalty_card_model.dart';
import 'package:loyaltyapp/services/api_client.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class ShopLoyaltyCard {
  final int id;
  final String name;
  final List<LoyaltyCard> loyaltyCards;

  ShopLoyaltyCard({
    required this.id,
    required this.name,
    required this.loyaltyCards,
  });

  factory ShopLoyaltyCard.fromJson(Map<String, dynamic> json) {
    print('Parsing ShopLoyaltyCard from JSON: $json');
    
    // Extract the loyalty cards array
    final loyaltyCardsJson = json['loyalty_cards'] as List<dynamic>? ?? [];
    print('Found ${loyaltyCardsJson.length} loyalty cards in shop');
    
    // Parse each loyalty card
    final loyaltyCards = loyaltyCardsJson.map<LoyaltyCard>((cardJson) {
      print('Parsing loyalty card: $cardJson');
      
      // Ensure we're passing all required fields to the LoyaltyCard model
      final card = LoyaltyCard.fromJson({
        'id': cardJson['id'],
        'shop_id': cardJson['shop_id'],
        'logo_url': cardJson['logo_url'],
        'color': cardJson['color'],
        'total_stamps': cardJson['total_stamps'],
        'description': cardJson['description'], // Make sure this is included
        'created_at': cardJson['created_at'],
        'updated_at': cardJson['updated_at'],
      });
      
      print('Parsed card:');
      print('- ID: ${card.id}');
      print('- Shop ID: ${card.shopId}');
      print('- Logo: ${card.logo}');
      print('- Color: ${card.backgroundColor}');
      print('- Total Stamps: ${card.totalStamps}');
      print('- Description: ${card.description}');
      
      return card;
    }).toList();
    
    final shopLoyaltyCard = ShopLoyaltyCard(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      loyaltyCards: loyaltyCards,
    );
    
    print('Created ShopLoyaltyCard:');
    print('- ID: ${shopLoyaltyCard.id}');
    print('- Name: ${shopLoyaltyCard.name}');
    print('- Number of cards: ${shopLoyaltyCard.loyaltyCards.length}');
    
    return shopLoyaltyCard;
  }
}


class LoyaltyCardService {
  final ApiClient _apiClient = ApiClient();

  // Fetch a user's loyalty card details
  Future<LoyaltyCard> getUserLoyaltyCard(int cardId) async {
    try {
      print('Fetching loyalty card with ID: $cardId');
      final response = await _apiClient.get('/user-loyalty-cards/$cardId');
      print('Received response: $response');
      final card = LoyaltyCard.fromJson(response);
      print('Parsed card: ${card.id}, Active stamps: ${card.activeStamps}');
      return card;
    } catch (e, stackTrace) {
      print('Error in getUserLoyaltyCard: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Subscribe to a loyalty card
  Future<LoyaltyCard> subscribeToLoyaltyCard(int cardId) async {
    try {
      final response = await _apiClient.post(
        '/loyalty-cards/$cardId/subscribe',
        data: {},
      );
      return LoyaltyCard.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Unsubscribe from a loyalty card
  Future<void> unsubscribeFromLoyaltyCard(int cardId) async {
    try {
      await _apiClient.delete('/loyalty-cards/$cardId/unsubscribe');
    } catch (e) {
      rethrow;
    }
  }

  // Get all user's loyalty cards
  Future<List<LoyaltyCard>> getUserLoyaltyCards() async {
    try {
      final response = await _apiClient.get('/user/loyalty-cards');
      return (response['data'] as List)
          .map((card) => LoyaltyCard.fromJson(card))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get active stamps for a loyalty card
  Future<int> getActiveStamps(int cardId) async {
    try {
      print('Fetching active stamps for card ID: $cardId');
      final response = await _apiClient.get('/user/loyalty-cards/$cardId/active-stamps');
      print('Active stamps response: $response');
      
      if (response['success'] == true) {
        return response['data']['active_stamps'] as int;
      }
      return 0;
    } catch (e, stackTrace) {
      print('Error getting active stamps: $e');
      print('Stack trace: $stackTrace');
      return 0;
    }
  }

  // Get loyalty cards for the authenticated user's shop
  Future<List<ShopLoyaltyCard>> getMyShopLoyaltyCards() async {
    try {
      final response = await _apiClient.get('/my-shops/loyalty-cards');
      if (response['success'] == true) {
        return (response['data'] as List)
            .map((shop) => ShopLoyaltyCard.fromJson(shop))
            .toList();
      }
      throw Exception('Failed to load shop loyalty cards');
    } catch (e) {
      print('Error in getMyShopLoyaltyCards: $e');
      rethrow;
    }
  }

  // Update loyalty card details
  Future<Map<String, dynamic>> updateLoyaltyCard({
    required int cardId,
    required String shopName,
    required String description,
    required String color,
    required int totalStamps,
    File? logoFile,
  }) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}/update-loyalty-card'),
      );

      // Add headers
      final token = await AuthService().getJwtToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['shop_name'] = shopName;
      request.fields['description'] = description;
      request.fields['color'] = color;
      request.fields['total_stamps'] = totalStamps.toString();

      // Add logo file if provided
      if (logoFile != null) {
        final fileStream = http.ByteStream(logoFile.openRead());
        final length = await logoFile.length();
        final multipartFile = http.MultipartFile(
          'logo',
          fileStream,
          length,
          filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update loyalty card');
      }
    } catch (e) {
      print('Error updating loyalty card: $e');
      rethrow;
    }
  }
}
