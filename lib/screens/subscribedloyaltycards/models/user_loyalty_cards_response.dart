import 'dart:convert';

class ShopCategory {
  final int id;
  final String name;
  final String icon;

  ShopCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }
}

class UserLoyaltyCardsResponse {
  final int userId;
  final int totalCards;
  final List<UserLoyaltyCard> loyaltyCards;

  UserLoyaltyCardsResponse({
    required this.userId,
    required this.totalCards,
    required this.loyaltyCards,
  });

  factory UserLoyaltyCardsResponse.fromJson(Map<String, dynamic> json) {
    return UserLoyaltyCardsResponse(
      userId: json['user_id'] as int,
      totalCards: json['total_cards'] as int,
      loyaltyCards: (json['loyalty_cards'] as List)
          .map((card) => UserLoyaltyCard.fromJson(card))
          .toList(),
    );
  }
}

class UserLoyaltyCard {
  final int id;
  final int activeStamps;
  final LoyaltyCard card;

  UserLoyaltyCard({
    required this.id,
    required this.activeStamps,
    required this.card,
  });

  factory UserLoyaltyCard.fromJson(Map<String, dynamic> json) {
    return UserLoyaltyCard(
      id: json['id'] as int,
      activeStamps: json['active_stamps'] as int,
      card: LoyaltyCard.fromJson(json['card']),
    );
  }
}

class LoyaltyCard {
  final int id;
  final String logo;
  final String color;
  final int totalStamps;
  final Shop shop;

  LoyaltyCard({
    required this.id,
    required this.logo,
    required this.color,
    required this.totalStamps,
    required this.shop,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as int,
      logo: json['logo'] as String,
      color: json['color'] as String,
      totalStamps: json['total_stamps'] as int,
      shop: Shop.fromJson(json['shop']),
    );
  }
}

class Shop {
  final int id;
  final String name;
  final List<String> images;
  final ShopCategory category;

  Shop({
    required this.id,
    required this.name,
    required this.images,
    required this.category,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Handle the case where images is a JSON string or already a List
    dynamic imagesData = json['images'];
    List<String> imagesList = [];
    
    if (imagesData is String) {
      try {
        // Try to parse the string as JSON
        final parsed = jsonDecode(imagesData);
        if (parsed is List) {
          imagesList = List<String>.from(parsed);
        }
      } catch (e) {
        // If parsing fails, use the string as a single item list
        imagesList = [imagesData];
      }
    } else if (imagesData is List) {
      imagesList = List<String>.from(imagesData);
    }
    
    return Shop(
      id: json['id'] as int,
      name: json['name'] as String,
      images: imagesList,
      category: ShopCategory.fromJson(json['category']),
    );
  }
}
