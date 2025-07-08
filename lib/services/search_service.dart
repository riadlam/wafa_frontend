import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/models/search_shop_model.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class SearchService {
  final String baseUrl = 'http://192.168.1.8:8000/api';
  final AuthService _authService = AuthService();

  Future<ShopSearchResponse> searchShops(String query) async {
    try {
      final token = await _authService.getJwtToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/shops/search?q=$query'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ShopSearchResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load search results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Add debouncing to prevent too many API calls
  static final Map<Function, DateTime> _functionTimestamps = {};
  
  Future<ShopSearchResponse> searchShopsDebounced(
    String query, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    // Cancel previous call if it was made within the duration
    if (_functionTimestamps.containsKey(searchShops) &&
        DateTime.now().difference(_functionTimestamps[searchShops]!) < duration) {
      await Future.delayed(duration);
    }
    
    _functionTimestamps[searchShops] = DateTime.now();
    
    // Wait for the duration before making the actual call
    await Future.delayed(duration);
    
    // Only proceed if this is the most recent call
    if (_functionTimestamps[searchShops]!.isAfter(
        DateTime.now().subtract(duration))) {
      return searchShops(query);
    }
    
    // Return empty response if this is not the most recent call
    return ShopSearchResponse(
      success: true,
      message: 'Cancelled',
      data: [],
    );
  }
}
