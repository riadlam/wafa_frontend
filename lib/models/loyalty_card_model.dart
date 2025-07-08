class LoyaltyCard {
  final int id;
  final int shopId;
  final String logo;  // This can be empty if no logo is available
  final String backgroundColor;
  final String? secondaryColor;
  final String? icon;  // Icon code (e.g., 'pizza', 'coffee')
  final String? description; // Description of the loyalty card
  final int totalStamps;
  final int? activeStamps;
  final int? userId;
  final bool? isSubscribed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LoyaltyCard({
    required this.id,
    required this.shopId,
    required this.logo,  // Can be empty
    required this.backgroundColor,
    this.secondaryColor,
    this.icon,
    this.description,
    required this.totalStamps,
    this.activeStamps = 0,
    this.userId,
    this.isSubscribed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    // Debug print to see the incoming JSON
    print('Parsing LoyaltyCard from JSON: $json');
    
    // Clean up the logo URL by removing any extra quotes and trimming whitespace
    String cleanLogoUrl(dynamic logo) {
      if (logo == null) return '';
      return logo.toString().replaceAll('"', '').trim();
    }
    
    // Helper to get logo URL from different possible field names
    String? getLogoUrl(Map<String, dynamic> json, Map<String, dynamic>? nested) {
      // Try to get from logo_url first (API response format)
      if (json['logo_url'] != null) {
        return cleanLogoUrl(json['logo_url']);
      }
      // Then try logo
      if (json['logo'] != null) {
        return cleanLogoUrl(json['logo']);
      }
      // Then try nested data
      if (nested != null) {
        if (nested['logo_url'] != null) return cleanLogoUrl(nested['logo_url']);
        if (nested['logo'] != null) return cleanLogoUrl(nested['logo']);
      }
      return null;
    }

    try {
      // Extract color from the JSON, trying different possible keys
      final backgroundColor = (json['color']?.toString().trim() ??
                            json['background_color']?.toString().trim() ??
                            json['backgroundColor']?.toString().trim() ??
                            '#6C63FF').toUpperCase();
      
      print('Parsed backgroundColor: $backgroundColor');
      
      // Extract description with null safety
      final description = json['description']?.toString();
      print('Parsed description: $description');
      
      // Extract other fields with null safety
      final totalStamps = (json['total_stamps'] is int) 
          ? json['total_stamps'] as int 
          : (int.tryParse(json['total_stamps']?.toString() ?? '') ?? 8);
          
      final activeStamps = (json['active_stamps'] is int)
          ? json['active_stamps'] as int
          : (int.tryParse(json['active_stamps']?.toString() ?? '') ?? 0);
          
      final logo = getLogoUrl(json, json) ?? '';
      
      // Parse timestamps if they exist
      final createdAt = json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null;
          
      final updatedAt = json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString())
          : null;
      
      final card = LoyaltyCard(
        id: (json['id'] ?? 0) as int,
        shopId: (json['shop_id'] ?? 0) as int,
        logo: logo,
        backgroundColor: backgroundColor,
        secondaryColor: json['secondary_color']?.toString(),
        icon: json['icon']?.toString(),
        description: description,
        totalStamps: totalStamps,
        activeStamps: activeStamps,
        userId: json['user_id'] as int?,
        isSubscribed: (json['is_subscribed'] ?? false) as bool,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      print('Created LoyaltyCard: $card');
      return card;
    } catch (e, stackTrace) {
      print('Error parsing LoyaltyCard from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Create a copy with updated fields
  LoyaltyCard copyWith({
    int? id,
    int? shopId,
    String? logo,
    String? backgroundColor,
    String? secondaryColor,
    String? icon,
    int? totalStamps,
    int? activeStamps,
    int? userId,
    bool? isSubscribed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      logo: logo ?? this.logo,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      icon: icon ?? this.icon,
      totalStamps: totalStamps ?? this.totalStamps,
      activeStamps: activeStamps ?? this.activeStamps,
      userId: userId ?? this.userId,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'logo': logo,
      'background_color': backgroundColor,
      'secondary_color': secondaryColor,
      'icon': icon,
      'total_stamps': totalStamps,
      'active_stamps': activeStamps,
      'user_id': userId,
      'is_subscribed': isSubscribed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
