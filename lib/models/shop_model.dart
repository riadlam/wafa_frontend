import 'dart:convert';
import 'package:hive/hive.dart';
import 'loyalty_card_model.dart';
import 'shop_location_model.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 3)
class ShopOwner extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String? googleId;
  
  @HiveField(4)
  final String? avatar;
  
  @HiveField(5)
  final String role;

  ShopOwner({
    required this.id,
    required this.name,
    required this.email,
    this.googleId,
    this.avatar,
    required this.role,
  });

  factory ShopOwner.fromJson(Map<String, dynamic> json) {
    return ShopOwner(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      googleId: json['google_id'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
    );
  }
}

@HiveType(typeId: 4)
class ShopCategory extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? icon;

  ShopCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }
}

@HiveType(typeId: 2)
class Shop extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int userId;
  
  @HiveField(2)
  final int categoryId;
  
  @HiveField(3)
  final String name;
  
  @HiveField(4)
  final String? contactInfo;
  
  @HiveField(5)
  final String? location;
  
  @HiveField(6)
  final ShopOwner owner;
  
  @HiveField(7)
  final ShopCategory category;
  
  @HiveField(8)
  final List<String>? images;
  
  @HiveField(9)
  final List<LoyaltyCard>? loyaltyCards;
  
  @HiveField(10)
  final List<ShopLocation>? shopLocations;

  Shop({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    this.contactInfo,
    this.location,
    required this.owner,
    required this.category,
    this.images,
    this.loyaltyCards,
    this.shopLocations,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Parse images from JSON string to List<String>
    List<String>? parseImages(dynamic imagesData) {
      if (imagesData == null) return null;
  
      // If it's already a list, return it directly
      if (imagesData is List) {
        return imagesData.map((e) => e.toString()).toList();
      }
  
      // If it's a string, try to parse it as JSON
      if (imagesData is String) {
        try {
          // Remove any extra quotes and parse the JSON array
          final cleanString = imagesData.replaceAll(r'\"', '"');
          if (cleanString.startsWith('[') && cleanString.endsWith(']')) {
            final parsed = jsonDecode(cleanString) as List;
            return parsed.map((e) => e.toString()).toList();
          }
          // If it's a single URL, return it as a list with one item
          if (cleanString.isNotEmpty) {
            return [cleanString];
          }
        } catch (e) {
          print('Error parsing images: $e');
          // If parsing fails but the string is not empty, return it as a single item list
          if (imagesData.trim().isNotEmpty) {
            return [imagesData];
          }
        }
      }
  
      return null;
    }

    // Handle case where category is not a full object
    final category = json['category'] is Map<String, dynamic>
        ? ShopCategory.fromJson(json['category'] as Map<String, dynamic>)
        : ShopCategory(
            id: json['category_id'] as int,
            name: 'Category ${json['category_id']}',
          );

    return Shop(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      contactInfo: json['contact_info'] as String?,
      location: json['location'] as String?,
      owner: ShopOwner.fromJson(json['owner'] as Map<String, dynamic>),
      category: category,
      images: parseImages(json['images']),
      loyaltyCards: json['loyalty_cards'] != null
          ? (json['loyalty_cards'] as List)
              .map((card) => LoyaltyCard.fromJson(card))
              .toList()
          : null,
      shopLocations: json['shop_locations'] != null
          ? (json['shop_locations'] as List)
              .map((location) => ShopLocation.fromJson(location))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'contact_info': contactInfo,
      'location': location,
      'owner': {
        'id': owner.id,
        'name': owner.name,
        'email': owner.email,
        'google_id': owner.googleId,
        'avatar': owner.avatar,
        'role': owner.role,
      },
      'category': {
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
      },
      'images': images,
      'loyalty_cards': loyaltyCards?.map((card) => card.toJson()).toList(),
      'shop_locations': shopLocations?.map((loc) => loc.toJson()).toList(),
    };
  }
}
