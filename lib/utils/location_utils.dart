import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUtils {
  static const String _userLatitudeKey = 'user_latitude';
  static const String _userLongitudeKey = 'user_longitude';

  static Future<double?> getDistanceInKm(double shopLat, double shopLng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userLat = prefs.getDouble(_userLatitudeKey);
      final userLng = prefs.getDouble(_userLongitudeKey);

      if (userLat == null || userLng == null) return null;

      final distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        shopLat,
        shopLng,
      );

      // Convert meters to kilometers and round to 1 decimal place
      return (distanceInMeters / 1000);
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  static Future<String?> getFormattedDistance(double shopLat, double shopLng) async {
    final distance = await getDistanceInKm(shopLat, shopLng);
    if (distance == null) return null;
    
    if (distance < 1) {
      // Show in meters if less than 1km
      return '${(distance * 1000).toInt()}m';
    } else {
      // Show in km with 1 decimal place if 1km or more
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
