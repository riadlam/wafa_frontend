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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'lat': lat,
      'lng': lng,
      'name': name,
    };
  }
}
