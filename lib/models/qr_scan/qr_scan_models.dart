class QRScanRequest {
  final String email;

  QRScanRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

class LoyaltyCard {
  final int id;
  final int shopId;
  final String logoUrl;
  final String color;
  final String description;
  final int totalStamps;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyCard({
    required this.id,
    required this.shopId,
    required this.logoUrl,
    required this.color,
    required this.description,
    required this.totalStamps,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        id: json['id'],
        shopId: json['shop_id'],
        logoUrl: json['logo_url'],
        color: json['color'],
        description: json['description'],
        totalStamps: json['total_stamps'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
}

class UserLoyaltyCard {
  final int id;
  final int userId;
  final int loyaltyCardId;
  final int activeStamps;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LoyaltyCard loyaltyCard;

  UserLoyaltyCard({
    required this.id,
    required this.userId,
    required this.loyaltyCardId,
    required this.activeStamps,
    this.createdAt,
    this.updatedAt,
    required this.loyaltyCard,
  });

  factory UserLoyaltyCard.fromJson(Map<String, dynamic> json) => UserLoyaltyCard(
        id: json['id'],
        userId: json['user_id'],
        loyaltyCardId: json['loyalty_card_id'],
        activeStamps: json['active_stamps'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        loyaltyCard: LoyaltyCard.fromJson(json['loyalty_card']),
      );
}

class QRScanResponse {
  final String status;
  final String message;
  final QRScanData data;

  QRScanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QRScanResponse.fromJson(Map<String, dynamic> json) => QRScanResponse(
        status: json['status'],
        message: json['message'],
        data: QRScanData.fromJson(json['data']),
      );
}

class QRScanData {
  final UserLoyaltyCard userLoyaltyCard;
  final int currentStamps;
  final int totalStampsNeeded;
  final bool stampReset;
  final String broadcastedMessage;

  QRScanData({
    required this.userLoyaltyCard,
    required this.currentStamps,
    required this.totalStampsNeeded,
    required this.stampReset,
    required this.broadcastedMessage,
  });

  factory QRScanData.fromJson(Map<String, dynamic> json) => QRScanData(
        userLoyaltyCard: UserLoyaltyCard.fromJson(json['user_loyalty_card']),
        currentStamps: json['current_stamps'],
        totalStampsNeeded: json['total_stamps_needed'],
        stampReset: json['stamp_reset'],
        broadcastedMessage: json['broadcasted_message'],
      );
}
