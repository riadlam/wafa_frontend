import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountService {
  static const String _baseUrl = 'http://192.168.1.15:8000/api';
  final _storage = const FlutterSecureStorage();

  Future<bool> deleteAccount() async {
    try {
      // Get the JWT token from secure storage
      final token = await _storage.read(key: 'jwt_token');
      
      if (token == null) {
        debugPrint('❌ [AccountService] No JWT token found');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/delete-account'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [AccountService] Account deleted successfully');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ [AccountService] Failed to delete account: ${errorData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [AccountService] Error deleting account: $e');
      return false;
    }
  }
}
