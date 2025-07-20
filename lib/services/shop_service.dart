import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/hive_models/hive_service.dart';
import 'package:loyaltyapp/services/api_client.dart';
import 'package:loyaltyapp/models/pending_payment_model.dart';

class ShopService {
  final ApiClient _apiClient = ApiClient();
  
  /// Fetches shop details from cache if available, otherwise from the API
  Future<Shop?> getShopDetails(int shopId) async {
    try {
      // First try to get from cache if it's still fresh
      if (!await HiveService.shouldFetchNewShopDetails(shopId)) {
        final cachedShop = await HiveService.getCachedShopDetails(shopId);
        if (cachedShop != null) {
          return cachedShop;
        }
      }
      
      // If cache is empty or stale, fetch from API
      final response = await _apiClient.get('/shops/$shopId');
      
      if (response == null) {
        throw Exception('Failed to fetch shop details');
      }
      
      // Parse the response
      Shop shop;
      if (response is Map) {
        shop = Shop.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
      
      // Save to cache for future use
      await HiveService.saveShopDetails(shop);
      return shop;
      
    } catch (e) {
      print('Error fetching shop details: $e');
      
      // Try to return from cache even if there was an error
      try {
        final cachedShop = await HiveService.getCachedShopDetails(shopId);
        if (cachedShop != null) {
          return cachedShop;
        }
      } catch (cacheError) {
        print('Error getting shop from cache: $cacheError');
      }
      
      rethrow;
    }
  }
  
  /// Fetches shops by category with caching support
  Future<List<Shop>> getShopsByCategory(int categoryId) async {
    try {
      // First try to get from cache if it's still fresh
      if (!await HiveService.shouldFetchNewShops(categoryId)) {
        final cachedShops = await HiveService.getCachedShops(categoryId);
        if (cachedShops.isNotEmpty) {
          return cachedShops.map((shopData) => 
            Shop.fromJson(shopData as Map<String, dynamic>)
          ).toList();
        }
      }
      
      // If cache is empty or stale, fetch from API
      final response = await _apiClient.get('/categories/$categoryId/shops');
      
      if (response == null) {
        throw Exception('Failed to fetch shops');
      }
      
      // Parse the response
      List<Shop> shops = [];
      
      if (response is List) {
        shops = response
            .where((item) => item != null)
            .map<Shop>((json) => Shop.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'] as List;
        shops = data
            .where((item) => item != null)
            .map<Shop>((json) => Shop.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
      
      // Save to cache for future use
      await HiveService.saveShops(categoryId, shops);
      return shops;
      
    } catch (e) {
      print('Error fetching shops: $e');
      
      // Try to return from cache even if there was an error
      try {
        final cachedShops = await HiveService.getCachedShops(categoryId);
        if (cachedShops.isNotEmpty) {
          return cachedShops.map((shopData) => 
            Shop.fromJson(shopData as Map<String, dynamic>)
          ).toList();
        }
      } catch (cacheError) {
        print('Error getting shops from cache: $cacheError');
      }
      
      rethrow;
    }
  }
}
