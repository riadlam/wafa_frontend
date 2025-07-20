import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final Logger _logger = Logger();
  
  // Base URL for your Laravel API
  static const String baseUrl = 'http://192.168.1.15:8000/api';
  
  // Singleton pattern
  factory ApiClient() => _instance;
  
  ApiClient._internal();
  
  // Get headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getJwtToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      _logger.e('API Error: ${response.statusCode} - ${response.body}');
      throw Exception(responseBody['message'] ?? 'An error occurred');
    }
  }
  
  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      final headers = await _getHeaders();
      
      // _logger.i('GET Request: $url');
      // _logger.i('Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      // _logger.i('Response Status: ${response.statusCode}');
      // _logger.i('Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e, stackTrace) {
      // _logger.e('GET request failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  // POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      // _logger.e('POST request failed: $e');
      rethrow;
    }
  }
  
  // PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      // _logger.e('PUT request failed: $e');
      rethrow;
    }
  }
  
  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      // _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }
}

// Global instance
final apiClient = ApiClient();
