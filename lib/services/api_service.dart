import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.15:8000/api';

  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, 
      {dynamic data, String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, 
      {dynamic data, String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = utf8.decode(response.bodyBytes);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) return {};
      return jsonDecode(responseBody);
    } else {
      final errorData = responseBody.isNotEmpty 
          ? jsonDecode(responseBody) 
          : {'message': 'Request failed with status: ${response.statusCode}'};
      throw Exception(errorData['message'] ?? 'An error occurred');
    }
  }
}
