import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/hive_models/hive_service.dart';
import 'package:loyaltyapp/models/stamp_activation_model.dart';
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
  static const String baseUrl = 'http://192.168.1.8:8000/api';

  final AuthService _authService = AuthService();

  Future<PlanInfo> getPlanInfo() async {
    try {
      // Ensure Hive is initialized
      await HiveService.ensureInitialized();
      
      // Try to get cached data first
      final cachedData = await HiveService.getCachedDashboardPlanInfo();
      if (cachedData != null) {
        developer.log('📦 [StampService] Using cached plan info');
        return PlanInfo.fromJson(cachedData);
      }
      
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
        final planInfo = PlanInfo.fromJson(data);
        
        // Cache the response
        await HiveService.saveDashboardPlanInfo({
          'plan': planInfo.plan,
          'expiration_date': planInfo.expirationDate,
          'expires_in': planInfo.expiresIn,
        });
        
        developer.log('📋 [StampService] Loaded plan: ${planInfo.plan}, Expires: ${planInfo.expiresIn}');
        return planInfo;
      } else {
        developer.log('❌ [StampService] Failed to load plan info: ${response.statusCode}');
        throw Exception('Failed to load plan info: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('⚠️ [StampService] Error fetching plan info: $e');
      // Return cached data if available, otherwise return default
      final cachedData = await HiveService.getCachedDashboardPlanInfo();
      if (cachedData != null) {
        return PlanInfo.fromJson(cachedData);
      }
      return PlanInfo(plan: 'Free', expirationDate: 'N/A', expiresIn: 'N/A');
    }
  }

  Future<List<StampActivation>> getRecentStamps() async {
    developer.log('🔄 [StampService] Starting to fetch recent stamps');
    
    try {
      // Ensure Hive is initialized
      await HiveService.ensureInitialized();
      
      // Try to get cached data first
      final cachedData = await HiveService.getCachedDashboardRecentStamps();
      if (cachedData != null) {
        developer.log('📦 [StampService] Using cached recent stamps');
        return cachedData.map((json) => StampActivation.fromJson(json)).toList().cast<StampActivation>();
      }
      
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
          
          // Cache the response
          await HiveService.saveDashboardRecentStamps(data);
          
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
      
      // If there's an error, try to return cached data if available
      final cachedData = await HiveService.getCachedDashboardRecentStamps();
      if (cachedData != null) {
        developer.log('🔄 [StampService] Falling back to cached recent stamps');
        return cachedData.map((json) => StampActivation.fromJson(json)).toList().cast<StampActivation>();
      }
      
      rethrow;
    } finally {
      developer.log('🏁 [StampService] Finished fetch operation');
    }
  }

  Future<Map<String, dynamic>> getRedemptionStats() async {
    developer.log('🔄 [StampService] Fetching redemption stats');
    
    try {
      // Ensure Hive is initialized
      await HiveService.ensureInitialized();
      
      // Try to get cached data first
      final cachedData = await HiveService.getCachedDashboardRedemptions();
      if (cachedData != null) {
        developer.log('📦 [StampService] Using cached redemption stats');
        return cachedData;
      }
      
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
        
        // Cache the response
        await HiveService.saveDashboardRedemptions(result);
        
        developer.log('📊 [StampService] Redemption stats: $result');
        return result;
      } else {
        developer.log('❌ [StampService] Failed to load redemption stats: ${response.statusCode}');
        return {'total_redemptions': 0};
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getRedemptionStats: $e');
      // Return cached data if available, otherwise return default
      final cachedData = await HiveService.getCachedDashboardRedemptions();
      return cachedData ?? {'total_redemptions': 0};
    }
  }

  Future<Map<String, dynamic>> getTotalSubscribers() async {
    developer.log('🔄 [StampService] Fetching total subscribers');
    
    try {
      // Ensure Hive is initialized
      await HiveService.ensureInitialized();
      
      // Try to get cached data first
      final cachedData = await HiveService.getCachedDashboardSubscribers();
      if (cachedData != null) {
        developer.log('📦 [StampService] Using cached subscribers data');
        return cachedData;
      }
      
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
        
        // Cache the response
        await HiveService.saveDashboardSubscribers(data);
        
        developer.log('📊 [StampService] Total subscribers: $data');
        return data;
      } else {
        developer.log('❌ [StampService] Failed to load total subscribers: ${response.statusCode}');
        return {'total_subscribers': 0};
      }
    } catch (e) {
      developer.log('❌ [StampService] Error in getTotalSubscribers: $e');
      // Return cached data if available, otherwise return default
      final cachedData = await HiveService.getCachedDashboardSubscribers();
      return cachedData ?? {'total_subscribers': 0};
    }
  }
}
