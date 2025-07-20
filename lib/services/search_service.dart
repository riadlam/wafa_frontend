import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/models/search_shop_model.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class SearchService {
  final String baseUrl = 'http://192.168.1.15:8000/api';
  final AuthService _authService = AuthService();

  Future<ShopSearchResponse> searchShops(String query) async {
    try {
      print('🔍 [SearchService] Searching for: "$query"');
      final token = await _authService.getJwtToken();
      
      if (token == null) {
        print('❌ [SearchService] No authentication token found');
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/shops/search?q=$query');
      print('🌐 [SearchService] Making request to: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 [SearchService] Response status: ${response.statusCode}');
      print('📦 [SearchService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic jsonData = jsonDecode(response.body);
          
          // Handle case where the API returns a list directly
          if (jsonData is List) {
            print('🔄 [SearchService] Received list response, converting to expected format');
            return ShopSearchResponse(
              success: true,
              message: 'Success',
              data: jsonData.map((item) => ShopSearchResult.fromJson(item)).toList(),
            );
          } 
          // Handle case where the API returns an object with data field
          else if (jsonData is Map<String, dynamic>) {
            return ShopSearchResponse.fromJson(jsonData);
          } 
          // Handle unexpected response format
          else {
            throw Exception('Unexpected response format: $jsonData');
          }
        } catch (e, stackTrace) {
          print('❌ [SearchService] Error parsing response: $e');
          print('📜 Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        final errorMsg = 'Failed to load search results: ${response.statusCode}';
        print('❌ [SearchService] $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      print('❌ [SearchService] Search failed: $e');
      print('📜 Stack trace: $stackTrace');
      rethrow;
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
