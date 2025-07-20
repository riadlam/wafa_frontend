class PendingPaymentResponse {
  final String status;
  final PendingPaymentData data;

  PendingPaymentResponse({
    required this.status,
    required this.data,
  });

  factory PendingPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PendingPaymentResponse(
      status: json['status'],
      data: PendingPaymentData.fromJson(json['data']),
    );
  }
}

class PendingPaymentData {
  final double totalAmountDue;
  final int unredeemedCount;
  final String oneUnitPrice;
  final List<PendingPaymentDetail> details;

  PendingPaymentData({
    required this.totalAmountDue,
    required this.unredeemedCount,
    required this.oneUnitPrice,
    required this.details,
  });

  factory PendingPaymentData.fromJson(Map<String, dynamic> json) {
    return PendingPaymentData(
      totalAmountDue: (json['total_amount_due'] as num).toDouble(),
      unredeemedCount: json['unredeemed_count'] as int,
      oneUnitPrice: json['one_unit_price'] as String,
      details: (json['details'] as List)
          .map((e) => PendingPaymentDetail.fromJson(e))
          .toList(),
    );
  }
}

class PendingPaymentDetail {
  final int loyaltyCardId;
  final String cardName;
  final int totalStamps;
  final String percentage;
  final int baseAmount;
  final int amountPerRedemption;
  final int unredeemedCount;
  final int amountForCard;

  PendingPaymentDetail({
    required this.loyaltyCardId,
    required this.cardName,
    required this.totalStamps,
    required this.percentage,
    required this.baseAmount,
    required this.amountPerRedemption,
    required this.unredeemedCount,
    required this.amountForCard,
  });

  factory PendingPaymentDetail.fromJson(Map<String, dynamic> json) {
    return PendingPaymentDetail(
      loyaltyCardId: json['loyalty_card_id'] as int,
      cardName: json['card_name'] as String,
      totalStamps: json['total_stamps'] as int,
      percentage: json['percentage'] as String,
      baseAmount: json['base_amount'] as int,
      amountPerRedemption: json['amount_per_redemption'] as int,
      unredeemedCount: json['unredeemed_count'] as int,
      amountForCard: json['amount_for_card'] as int,
    );
  }
}
