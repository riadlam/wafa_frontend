import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/models/stamp_activation_model.dart';
import 'package:loyaltyapp/models/pending_payment_model.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class PlanInfo {
  final String plan;
  final String expirationDate;
  final String expiresIn;

  PlanInfo({
    required this.plan,
    required this.expirationDate,
    required this.expiresIn,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) {
    return PlanInfo(
      plan: json['plan'] ?? 'Free',
      expirationDate: json['expiration_date'] ?? 'N/A',
      expiresIn: json['expires_in'] ?? 'N/A',
    );
  }
}

class StampService {
  static const String baseUrl = 'http://192.168.1.15:8000/api';

  final AuthService _authService = AuthService();

  Future<PlanInfo> getPlanInfo() async {
    try {
      final token = await _authService.getJwtToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      developer.log('🌐 [StampService] Fetching plan info from: $baseUrl/user/plan-info');
      final response = await http.get(
        Uri.parse('$baseUrl/user/plan-info'),
        headers: headers,
      );

      developer.log('✅ [StampService] Plan info response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PlanInfo.fromJson(data);
      } else {
        developer.log('❌ [StampService] Failed to load plan info: ${response.statusCode}');
        throw Exception('Failed to load plan info: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('⚠️ [StampService] Error fetching plan info: $e');
      rethrow;
    }
  }

  Future<List<StampActivation>> getRecentStamps() async {
    developer.log('🔄 [StampService] Starting to fetch recent stamps');
    
    try {
      developer.log('🔑 [StampService] Retrieving auth token...');
      final token = await _authService.getJwtToken();
      
      final headers = {
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        developer.log('⚠️ [StampService] No authentication token found');
      }

      developer.log('🌐 [StampService] Making API request to: $baseUrl/user/recent-stamps');
      final response = await http.get(
        Uri.parse('$baseUrl/user/recent-stamps'),
        headers: headers,
      );

      developer.log('✅ [StampService] Received response with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          developer.log('📊 [StampService] Successfully parsed ${data.length} stamp activations');
          return data.map((json) => StampActivation.fromJson(json)).toList();
        } catch (e) {
          developer.log('❌ [StampService] Error parsing response: $e');
          developer.log('Response body: ${response.body}');
          throw Exception('Error parsing stamp activations: $e');
        }
      } else {
        developer.log('❌ [StampService] API request failed with status: ${response.statusCode}');
        developer.log('Response body: ${response.body}');
        throw Exception('Failed to load recent stamps: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getRecentStamps: $e');
      rethrow;
    } finally {
      developer.log('🏁 [StampService] Finished fetch operation');
    }
  }

  Future<Map<String, dynamic>> getRedemptionStats() async {
    developer.log('🔄 [StampService] Fetching redemption stats');
    
    try {
      final token = await _authService.getJwtToken();
      final headers = {
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        developer.log('⚠️ [StampService] No authentication token found for redemption stats');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/shop/redemption-stats'),
        headers: headers,
      );

      developer.log('✅ [StampService] Redemption stats response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data'] ?? {'total_redemptions': 0};
        
        developer.log('📊 [StampService] Redemption stats: $result');
        return result;
      } else {
        developer.log('❌ [StampService] Failed to load redemption stats: ${response.statusCode}');
        return {'total_redemptions': 0};
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getRedemptionStats: $e');
      return {'total_redemptions': 0};
    }
  }

  Future<PendingPaymentResponse> getPendingPayment() async {
    developer.log('🔄 [StampService] Fetching pending payment');
    
    try {
      final token = await _authService.getJwtToken();
      final headers = {
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        developer.log('⚠️ [StampService] No authentication token found for pending payment');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/shop/calculate-amount-due'),
        headers: headers,
      );

      developer.log('✅ [StampService] Pending payment response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PendingPaymentResponse.fromJson(data);
      } else {
        developer.log('❌ [StampService] Failed to load pending payment: ${response.statusCode}');
        throw Exception('Failed to load pending payment');
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getPendingPayment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTotalSubscribers() async {
    developer.log('🔄 [StampService] Fetching total subscribers');
    
    try {
      final token = await _authService.getJwtToken();
      final headers = {
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        developer.log('⚠️ [StampService] No authentication token found for total subscribers');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/shop/total-subscribers'),
        headers: headers,
      );

      developer.log('✅ [StampService] Total subscribers response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract the data field if it exists, otherwise use the whole response
        final result = data is Map && data.containsKey('data') 
            ? data['data'] 
            : data;
            
        developer.log('📊 [StampService] Total subscribers: $result');
        return result;
      } else {
        developer.log('❌ [StampService] Failed to load total subscribers: ${response.statusCode}');
        return {'total_subscribers': 0};
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getTotalSubscribers: $e');
      return {'total_subscribers': 0};
    }
  }
}
