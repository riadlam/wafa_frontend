import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loyaltyapp/models/category_model.dart' as category_model;
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/user_loyalty_cards_response.dart' as loyalty_models;

class HiveService {
  // Categories cache
  static const String _categoriesBox = 'categories_box';
  static const String _categoriesMetadataKey = 'categories_last_updated';
  
  // Shops cache
  static const String _shopsBox = 'shops_box';
  static const String _shopsMetadataKey = 'shops_last_updated';
  static const String _shopDetailsBox = 'shop_details_box';
  static const String _shopDetailsMetadataKey = 'shop_details_last_updated';
  
  // Loyalty Cards cache
  static const String _loyaltyCardsBox = 'loyalty_cards_box';
  static const String _loyaltyCardsMetadataKey = 'loyalty_cards_last_updated';
  static const String _shopLoyaltyCardsBox = 'shop_loyalty_cards_box';
  static const String _shopLoyaltyCardsMetadataKey = 'shop_loyalty_cards_last_updated';
  
  // Admin Dashboard cache
  static const String _dashboardBox = 'dashboard_box';
  static const String _dashboardPlanInfoKey = 'dashboard_plan_info';
  static const String _dashboardSubscribersKey = 'dashboard_subscribers';
  static const String _dashboardRedemptionsKey = 'dashboard_redemptions';
  static const String _dashboardRecentStampsKey = 'dashboard_recent_stamps';
  
  // Local Shop model for serialization
  static Map<String, dynamic> _shopToJson(loyalty_models.Shop shop) {
    return {
      'id': shop.id,
      'name': shop.name,
      'images': shop.images,
      'category': {
        'id': shop.category.id,
        'name': shop.category.name,
        'icon': shop.category.icon,
      },
    };
  }
  
  static loyalty_models.Shop _shopFromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] as Map<String, dynamic>? ?? {};
    final category = loyalty_models.ShopCategory(
      id: categoryData['id'] as int? ?? 0,
      name: categoryData['name'] as String? ?? 'Category',
      icon: categoryData['icon'] as String? ?? 'star',
    );
    
    return loyalty_models.Shop(
      id: json['id'] as int,
      name: json['name'] as String,
      images: List<String>.from(json['images'] as List),
      category: category,
    );
  }
  
  static const Duration _cacheDuration = Duration(hours: 1);

  static bool _isInitialized = false;
  
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(category_model.CategoryAdapter());
      }
      
      // Open boxes
      await Future.wait([
        Hive.openBox<category_model.Category>(_categoriesBox),
        Hive.openBox<Map<dynamic, dynamic>>(_shopsBox),
        Hive.openBox<Map<dynamic, dynamic>>(_loyaltyCardsBox),
        Hive.openBox<Map<dynamic, dynamic>>(_shopDetailsBox),
        Hive.openBox<Map<dynamic, dynamic>>(_shopLoyaltyCardsBox),
        Hive.openBox<Map<dynamic, dynamic>>(_dashboardBox),
        Hive.openBox<String>('metadata'),
      ]);
      
      _isInitialized = true;
    }
  }

  // Categories cache methods
  static Future<void> saveCategories(List<category_model.Category> categories) async {
    final box = Hive.box<category_model.Category>(_categoriesBox);
    await box.clear();
    await box.addAll(categories);
    
    // Update the timestamp
    final metadataBox = Hive.box<String>('metadata');
    await metadataBox.put(_categoriesMetadataKey, DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Future<List<category_model.Category>> getCachedCategories() async {
    final box = Hive.box<category_model.Category>(_categoriesBox);
    return box.values.toList();
  }

  static Future<bool> shouldFetchNewCategories() async {
    final metadataBox = Hive.box<String>('metadata');
    final lastUpdatedStr = metadataBox.get(_categoriesMetadataKey, defaultValue: '0');
    final lastUpdated = int.tryParse(lastUpdatedStr ?? '0') ?? 0;
    
    if (lastUpdated == 0) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _cacheDuration.inMilliseconds;
  }
  
  // Shops cache methods
  static Future<void> saveShops(int categoryId, List<dynamic> shops) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopsBox);
      
      // Convert shops to a list of maps
      final shopsData = shops.map((shop) => shop.toJson()).toList();
      
      // Save shops with category ID as key
      await box.put(categoryId, {
        'shops': shopsData,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      
      // Update metadata
      final metadataBox = Hive.box<String>('metadata');
      await metadataBox.put('${_shopsMetadataKey}_$categoryId', DateTime.now().millisecondsSinceEpoch.toString());
    } catch (e) {
      print('Error saving shops to cache: $e');
      rethrow;
    }
  }
  
  static Future<List<dynamic>> getCachedShops(int categoryId) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopsBox);
      final data = box.get(categoryId);
      
      if (data == null || data['shops'] == null) {
        return [];
      }
      
      // Check if cache is still valid
      final timestamp = data['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
        return [];
      }
      
      // Return the raw shop data - let the caller handle the conversion
      return data['shops'] is List ? List<Map<String, dynamic>>.from(data['shops']) : [];
    } catch (e) {
      print('Error getting cached shops: $e');
      return [];
    }
  }
  
  static Future<bool> shouldFetchNewShops(int categoryId) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_shopsBox);
    final data = box.get(categoryId);
    
    if (data == null) return true;
    
    final timestamp = data['timestamp'] as int? ?? 0;
    if (timestamp == 0) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) > _cacheDuration.inMilliseconds;
  }

  // Shop Details cache methods
  static Future<void> saveShopDetails(Shop shop) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopDetailsBox);
      final metadataBox = Hive.box<String>('metadata');
      
      // Convert shop to map and add timestamp
      final shopData = {
        'shop': shop.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Save shop with its ID as the key
      await box.put(shop.id, shopData);
      await metadataBox.put(
        '${_shopDetailsMetadataKey}_${shop.id}', 
        DateTime.now().millisecondsSinceEpoch.toString()
      );
    } catch (e) {
      print('Error saving shop details to cache: $e');
      rethrow;
    }
  }

  static Future<Shop?> getCachedShopDetails(int shopId) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopDetailsBox);
      final data = box.get(shopId);
      
      if (data == null || data['shop'] == null) {
        return null;
      }
      
      // Check if cache is still valid
      final timestamp = data['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
        return null;
      }
      
      // Convert the data back to a Shop object
      return Shop.fromJson(Map<String, dynamic>.from(data['shop'] as Map));
    } catch (e) {
      print('Error getting cached shop details: $e');
      return null;
    }
  }

  static Future<bool> shouldFetchNewShopDetails(int shopId) async {
    final metadataBox = Hive.box<String>('metadata');
    final lastUpdatedStr = metadataBox.get(
      '${_shopDetailsMetadataKey}_$shopId', 
      defaultValue: '0'
    );
    final lastUpdated = int.tryParse(lastUpdatedStr ?? '0') ?? 0;
    
    if (lastUpdated == 0) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _cacheDuration.inMilliseconds;
  }
  
  // Loyalty Cards cache methods
  static Future<void> saveLoyaltyCards(loyalty_models.UserLoyaltyCardsResponse loyaltyCards) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_loyaltyCardsBox);
      final metadataBox = Hive.box<String>('metadata');
      
      // Convert loyalty cards to a list of maps
      final cardsData = {
        'user_id': loyaltyCards.userId,
        'total_cards': loyaltyCards.totalCards,
        'loyalty_cards': loyaltyCards.loyaltyCards.map((userCard) {
          final card = userCard.card;
          
          return {
            'id': userCard.id,
            'active_stamps': userCard.activeStamps,
            'card': {
              'id': card.id,
              'logo': card.logo,
              'color': card.color,
              'total_stamps': card.totalStamps,
              'shop': _shopToJson(card.shop),
            }
          };
        }).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await box.put('user_cards', cardsData);
      await metadataBox.put(_loyaltyCardsMetadataKey, DateTime.now().millisecondsSinceEpoch.toString());
    } catch (e) {
      print('Error saving loyalty cards to cache: $e');
      rethrow;
    }
  }
  
  static Future<loyalty_models.UserLoyaltyCardsResponse?> getCachedLoyaltyCards() async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_loyaltyCardsBox);
      final data = box.get('user_cards');
      
      if (data == null) return null;
      
      // Check if cache is still valid
      final timestamp = data['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
        return null;
      }
      
      // Convert the data to the expected format for UserLoyaltyCardsResponse
      final responseData = {
        'user_id': data['user_id'],
        'total_cards': data['total_cards'],
        'loyalty_cards': (data['loyalty_cards'] as List).map((cardData) {
          final card = cardData['card'] as Map<String, dynamic>;
          
          return {
            'id': cardData['id'],
            'active_stamps': cardData['active_stamps'],
            'card': {
              'id': card['id'],
              'logo': card['logo'],
              'color': card['color'],
              'total_stamps': card['total_stamps'],
              'shop': card['shop'], // Already in the correct format
            }
          };
        }).toList(),
      };
      
      return loyalty_models.UserLoyaltyCardsResponse.fromJson(
        Map<String, dynamic>.from(responseData)
      );
    } catch (e) {
      print('Error getting cached loyalty cards: $e');
      return null;
    }
  }
  
  static Future<bool> shouldFetchNewLoyaltyCards() async {
    final metadataBox = Hive.box<String>('metadata');
    final lastUpdatedStr = metadataBox.get(_loyaltyCardsMetadataKey, defaultValue: '0');
    final lastUpdated = int.tryParse(lastUpdatedStr ?? '0') ?? 0;
    
    if (lastUpdated == 0) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _cacheDuration.inMilliseconds;
  }

  // Shop Loyalty Card cache methods
  static Future<void> saveShopLoyaltyCard(int shopId, Map<String, dynamic> loyaltyCardData) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopLoyaltyCardsBox);
      final metadataBox = Hive.box<String>('metadata');
      
      final cardData = {
        'data': loyaltyCardData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await box.put(shopId, cardData);
      await metadataBox.put(
        '${_shopLoyaltyCardsMetadataKey}_$shopId',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      print('Error saving shop loyalty card to cache: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCachedShopLoyaltyCard(int shopId) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_shopLoyaltyCardsBox);
      final data = box.get(shopId);
      
      if (data == null || data['data'] == null) {
        return null;
      }
      
      // Check if cache is still valid
      final timestamp = data['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
        return null;
      }
      
      return Map<String, dynamic>.from(data['data'] as Map);
    } catch (e) {
      print('Error getting cached shop loyalty card: $e');
      return null;
    }
  }

  static Future<bool> shouldFetchNewShopLoyaltyCard(int shopId) async {
    final metadataBox = Hive.box<String>('metadata');
    final lastUpdatedStr = metadataBox.get(
      '${_shopLoyaltyCardsMetadataKey}_$shopId',
      defaultValue: '0',
    );
    final lastUpdated = int.tryParse(lastUpdatedStr ?? '0') ?? 0;
    
    if (lastUpdated == 0) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _cacheDuration.inMilliseconds;
  }

  // Admin Dashboard Cache Methods
  static Future<void> saveDashboardPlanInfo(Map<String, dynamic> planInfo) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    await box.put(_dashboardPlanInfoKey, {
      'data': planInfo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<Map<String, dynamic>?> getCachedDashboardPlanInfo() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    final data = box.get(_dashboardPlanInfoKey);
    
    if (data == null) return null;
    
    final timestamp = data['timestamp'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
      return null;
    }
    
    return Map<String, dynamic>.from(data['data'] as Map);
  }

  static Future<void> saveDashboardSubscribers(Map<String, dynamic> subscribers) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    await box.put(_dashboardSubscribersKey, {
      'data': subscribers,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<Map<String, dynamic>?> getCachedDashboardSubscribers() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    final data = box.get(_dashboardSubscribersKey);
    
    if (data == null) return null;
    
    final timestamp = data['timestamp'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
      return null;
    }
    
    return Map<String, dynamic>.from(data['data'] as Map);
  }

  static Future<void> saveDashboardRedemptions(Map<String, dynamic> redemptions) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    await box.put(_dashboardRedemptionsKey, {
      'data': redemptions,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<Map<String, dynamic>?> getCachedDashboardRedemptions() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
    final data = box.get(_dashboardRedemptionsKey);
    
    if (data == null) return null;
    
    final timestamp = data['timestamp'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
      return null;
    }
    
    return Map<String, dynamic>.from(data['data'] as Map);
  }

  static Future<void> saveDashboardRecentStamps(List<dynamic> recentStamps) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
      // Convert the list of dynamic to a list of maps
      final serializedStamps = recentStamps
          .map((stamp) => stamp is Map ? Map<String, dynamic>.from(stamp) : <String, dynamic>{})
          .toList();
          
      await box.put(_dashboardRecentStampsKey, {
        'data': serializedStamps,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      developer.log('Error saving recent stamps to cache: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> getCachedDashboardRecentStamps() async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_dashboardBox);
      final data = box.get(_dashboardRecentStampsKey);
      
      if (data == null) return null;
      
      final timestamp = data['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (timestamp == 0 || (now - timestamp) > _cacheDuration.inMilliseconds) {
        return null;
      }
      
      // Safely convert the data to List<Map<String, dynamic>>
      final rawData = data['data'] is List ? List<dynamic>.from(data['data'] as List) : <dynamic>[];
      return rawData
          .whereType<Map<dynamic, dynamic>>()
          .map<Map<String, dynamic>>((map) => Map<String, dynamic>.from(map))
          .toList();
    } catch (e) {
      developer.log('Error getting cached recent stamps: $e');
      return null;
    }
  }
}
