import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class CategoryService {
  static const String baseUrl = 'http://192.168.1.15:8000/api';

  static Future<List<Category>> getCategories() async {
    try {
      final token = await AuthService().getJwtToken();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
