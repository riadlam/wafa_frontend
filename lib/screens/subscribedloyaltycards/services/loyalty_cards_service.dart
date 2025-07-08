import 'package:loyaltyapp/services/api_client.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/user_loyalty_cards_response.dart';
import 'package:loyaltyapp/hive_models/hive_service.dart';

class LoyaltyCardsService {
  final ApiClient _apiClient = ApiClient();

  Future<UserLoyaltyCardsResponse> getUserLoyaltyCards() async {
    try {
      // First check if we have valid cached data
      final cachedResponse = await HiveService.getCachedLoyaltyCards();
      if (cachedResponse != null) {
        return cachedResponse;
      }

      // If no valid cache, fetch from API
      final response = await _apiClient.get('/user/loyalty-cards');
      final loyaltyCards = UserLoyaltyCardsResponse.fromJson(response);
      
      // Save to cache
      await HiveService.saveLoyaltyCards(loyaltyCards);
      
      return loyaltyCards;
    } catch (e) {
      // If API call fails, try to return cached data if available
      final cachedResponse = await HiveService.getCachedLoyaltyCards();
      if (cachedResponse != null) {
        return cachedResponse;
      }
      
      // If no cached data available, rethrow the error
      rethrow;
    }
  }
  
  // Force refresh the loyalty cards from the API
  Future<UserLoyaltyCardsResponse> refreshLoyaltyCards() async {
    try {
      final response = await _apiClient.get('/user/loyalty-cards');
      final loyaltyCards = UserLoyaltyCardsResponse.fromJson(response);
      
      // Update cache
      await HiveService.saveLoyaltyCards(loyaltyCards);
      
      return loyaltyCards;
    } catch (e) {
      // If refresh fails, try to return cached data if available
      final cachedResponse = await HiveService.getCachedLoyaltyCards();
      if (cachedResponse != null) {
        return cachedResponse;
      }
      
      // If no cached data available, rethrow the error
      rethrow;
    }
  }
}
