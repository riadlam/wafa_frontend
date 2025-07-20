class ShopSearchResponse {
  final bool success;
  final String message;
  final List<ShopSearchResult> data;

  ShopSearchResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ShopSearchResponse.fromJson(Map<String, dynamic> json) {
    return ShopSearchResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ShopSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ShopSearchResult {
  final int id;
  final String name;
  final String? contactInfo;
  final String? location;
  final List<String>? images;  // Changed from String? image to List<String>? images
  final String categoryName;
  final List<LoyaltyCard> loyaltyCards;
  final List<ShopLocation> shopLocations;
  final Owner owner;

  ShopSearchResult({
    required this.id,
    required this.name,
    this.contactInfo,
    this.location,
    this.images,
    required this.categoryName,
    required this.loyaltyCards,
    required this.shopLocations,
    required this.owner,
  });

  factory ShopSearchResult.fromJson(Map<String, dynamic> json) {
    return ShopSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      contactInfo: json['contact_info'] as String?,
      location: json['location'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      categoryName: json['category_name'] as String? ?? 'No Category',
      loyaltyCards: (json['loyalty_cards'] as List<dynamic>?)
              ?.map((e) => LoyaltyCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shopLocations: (json['shop_locations'] as List<dynamic>?)
              ?.map((e) => ShopLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
    );
  }
}

class LoyaltyCard {
  final int id;
  final int shopId;
  final String? logo;
  final String backgroundColor;
  final int totalStamps;

  LoyaltyCard({
    required this.id,
    required this.shopId,
    this.logo,
    required this.backgroundColor,
    required this.totalStamps,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as int,
      shopId: json['shop_id'] as int,
      logo: json['logo'] as String?,
      backgroundColor: json['background_color'] as String? ?? '#4caf50',
      totalStamps: json['total_stamps'] as int? ?? 0,
    );
  }
}

class ShopLocation {
  final int id;
  final int shopId;
  final double lat;
  final double lng;
  final String name;

  ShopLocation({
    required this.id,
    required this.shopId,
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory ShopLocation.fromJson(Map<String, dynamic> json) {
    return ShopLocation(
      id: json['id'] as int,
      shopId: json['shop_id'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
    );
  }
}

class Owner {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  Owner({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }
}
