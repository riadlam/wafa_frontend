import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/constants/api_constants.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class SubscriptionService {
  final String _baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  // Activate free trial
  Future<Map<String, dynamic>> activateFreeTrial() async {
    try {
      final token = await _authService.getJwtToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/setup-shop-owner'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'plan_type': 'free_trial',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to activate free trial');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
