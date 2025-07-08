import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loyaltyapp/constants/algerian_wilayas.dart';
import 'package:loyaltyapp/hive_models/hive_service.dart';
import 'package:loyaltyapp/models/category_model.dart';
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/services/api_client.dart';
import 'package:loyaltyapp/services/auth_service.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<Category>> getCategories() async {
    try {
      // First try to get categories from cache if they're still fresh
      if (!await HiveService.shouldFetchNewCategories()) {
        final cachedCategories = await HiveService.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return cachedCategories;
        }
      }
      
      // If cache is empty or stale, fetch from API
      final response = await _apiClient.get('/categories');
      List<Category> categories = [];
      
      if (response is Map && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        categories = data.map((json) => Category.fromJson(json)).toList();
      } else if (response is List) {
        categories = response.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
      
      // Save to cache for future use
      await HiveService.saveCategories(categories);
      return categories;
      
    } catch (e) {
      print('Error fetching categories: $e');
      // Try to return from cache even if there was an error
      try {
        final cachedCategories = await HiveService.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return cachedCategories;
        }
      } catch (cacheError) {
        print('Error getting categories from cache: $cacheError');
      }
      
      // If all else fails, return default categories
      return [
        Category(id: 1, name: 'Restaurants'),
        Category(id: 2, name: 'Cafes'),
        Category(id: 3, name: 'Italian'),
        Category(id: 4, name: 'American'),
        Category(id: 5, name: 'Japanese'),
        Category(id: 6, name: 'Desserts'),
      ];
    }
  }

  Future<List<Shop>> getShopsByCategory(int categoryId) async {
    try {
      // First try to get shops from cache if they're still fresh
      if (!await HiveService.shouldFetchNewShops(categoryId)) {
        final cachedShops = await HiveService.getCachedShops(categoryId);
        if (cachedShops.isNotEmpty) {
          // Convert the dynamic list to List<Shop>
          return cachedShops.map((shopData) => 
            Shop.fromJson(shopData as Map<String, dynamic>)
          ).toList();
        }
      }
      
      // If cache is empty or stale, fetch from API
      final response = await _apiClient.get('/categories/$categoryId/shops');
      
      if (response == null) {
        print('API response is null');
        return [];
      }

      List<Shop> shops = [];
      
      if (response is List) {
        shops = response
            .where((item) => item != null)
            .map<Shop?>((json) {
              try {
                return Shop.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing shop: $e');
                return null;
              }
            })
            .whereType<Shop>()
            .toList();
      } else if (response is Map) {
        if (response.containsKey('data') && response['data'] is List) {
          final data = response['data'] as List;
          shops = data
              .where((item) => item != null)
              .map<Shop?>((json) {
                try {
                  return Shop.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing shop from data: $e');
                  return null;
                }
              })
              .whereType<Shop>()
              .toList();
        }
      }
      
      // Save to cache for future use
      if (shops.isNotEmpty) {
        await HiveService.saveShops(categoryId, shops);
      }
      
      return shops;
      
    } catch (e) {
      print('Error fetching shops for category $categoryId: $e');
      
      // Try to return from cache even if there was an error
      try {
        final cachedShops = await HiveService.getCachedShops(categoryId);
        if (cachedShops.isNotEmpty) {
          // Convert the dynamic list to List<Shop>
          return cachedShops.map((shopData) => 
            Shop.fromJson(shopData as Map<String, dynamic>)
          ).toList();
        }
      } catch (cacheError) {
        print('Error getting shops from cache: $cacheError');
      }
      
      // If all else fails, return an empty list
      return [];
    }
  }

  // New method to filter shops by wilaya
  Future<List<Shop>> getShopsByWilayaAndCategory(int categoryId, String wilaya) async {
    try {
      final token = await AuthService().getJwtToken();
      final response = await http.get(
        Uri.parse('http://192.168.1.8:8000/api/locations/filter?wilaya=$wilaya&category_id=$categoryId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .where((item) => item != null)
            .map<Shop>((json) => Shop.fromJson(json))
            .toList();
      } else {
        print('Failed to load shops by wilaya: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching shops by wilaya: $e');
      return [];
    }
  }
}
