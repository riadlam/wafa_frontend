import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/custom_app_bar.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/user_loyalty_cards_response.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/services/loyalty_cards_service.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/widgets/loyalty_card_item.dart';
import 'package:flutter/services.dart';
import 'package:loyaltyapp/scalaton_loader/loyalty_card_skeleton.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide_icons;
import 'package:lucide_icons/lucide_icons.dart';

class SbscribedLoyaltyCards extends StatefulWidget {
  const SbscribedLoyaltyCards({super.key});

  @override
  State<SbscribedLoyaltyCards> createState() => _SbscribedLoyaltyCardsState();
}

class _SbscribedLoyaltyCardsState extends State<SbscribedLoyaltyCards> {
  final LoyaltyCardsService _loyaltyCardsService = LoyaltyCardsService();
  late Future<UserLoyaltyCardsResponse> _loyaltyCardsFuture;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyCards();
  }

  Future<void> _loadLoyaltyCards({bool forceRefresh = false}) async {
    setState(() {
      _loyaltyCardsFuture = forceRefresh
          ? _loyaltyCardsService.refreshLoyaltyCards()
          : _loyaltyCardsService.getUserLoyaltyCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Cards'),
      body: FutureBuilder<UserLoyaltyCardsResponse>(
        future: _loyaltyCardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load loyalty cards'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadLoyaltyCards,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final response = snapshot.data!;

          if (response.totalCards == 0) {
            return const Center(
              child: Text('You have no loyalty cards yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _loadLoyaltyCards(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: response.loyaltyCards.length,
              itemBuilder: (context, index) {
                final card = response.loyaltyCards[index];
                // Create a unique identifier for the card
                final cardId = '${card.card.id}_${card.card.shop.id}';

                // Debug log the category and icon details
                final categoryIcon = card.card.shop.category.icon;
                debugPrint('Card: ${card.card.shop.name}');
                debugPrint('Category: ${card.card.shop.category.name}');
                debugPrint('Raw icon name from API: "$categoryIcon"');
                debugPrint('Icon type: ${categoryIcon.runtimeType}');

                // Get the icon
                final icon = _getCategoryIcon(categoryIcon);
                debugPrint('Resolved icon: $icon');

                return LoyaltyCardItem(
                  card: LoyaltyCardModel(
                    id: cardId,
                    name: card.card.shop.name,
                    description: card.card.shop.category.name,
                    totalStamps: card.card.totalStamps,
                    earnedStamps: card.activeStamps,
                    isSubscribed: true,
                    icon: icon, // Pass the resolved icon
                    imageUrl: card.card.logo,
                    backgroundColor: _parseColor(card.card.color,
                        fallback: const Color(0xFFFF8C42)),
                    secondaryColor: _parseColor(card.card.color,
                        fallback: const Color(0xFFFFB347)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Helper method to get category icon
IconData _getCategoryIcon(String iconName) {
  debugPrint('Getting icon for: $iconName');

  // Map of icon names to LucideIcons
  final iconMap = {
    // Exact matches
    'perfume': LucideIcons.sprayCan,
    'hair': LucideIcons.scissors,
    'ruler': LucideIcons.ruler,
    'cupSoda': LucideIcons.cupSoda, // camelCase version
    'cupsoda': LucideIcons.cupSoda, // lowercase version
    'cup_soda': LucideIcons.cupSoda, // snake_case version
    'sandwich': LucideIcons.sandwich,
    'coffee': LucideIcons.coffee,
    'utensils': LucideIcons.utensils,
    'shopping-bag': LucideIcons.shoppingBag,
    'shoppingbag': LucideIcons.shoppingBag,
    'shoppingBag': LucideIcons.shoppingBag, // camelCase version
    'shirt': LucideIcons.shirt,
    'smartphone': LucideIcons.smartphone,
    'home': LucideIcons.home,
    'heart': LucideIcons.heart,
    'gift': LucideIcons.gift,
    'ticket': LucideIcons.ticket,
    'spray-can': LucideIcons.sprayCan, // Alternative format
    'spraycan': LucideIcons.sprayCan, // No hyphen
  };

  // Try exact match first (case sensitive)
  if (iconMap.containsKey(iconName)) {
    debugPrint('Found exact match for: $iconName');
    return iconMap[iconName]!;
  }

  // Normalize the icon name (lowercase and remove special characters)
  final normalizedIconName =
      iconName.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');

  // Try to find the icon in our map with normalized name
  if (iconMap.containsKey(normalizedIconName)) {
    debugPrint('Found normalized match for: $iconName -> $normalizedIconName');
    return iconMap[normalizedIconName]!;
  }

  // Try to find by converting to camelCase (e.g., 'cup_soda' -> 'cupSoda')
  final camelCaseName = normalizedIconName.split('_').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join('');

  if (camelCaseName.isNotEmpty && iconMap.containsKey(camelCaseName)) {
    debugPrint('Found camelCase match for: $iconName -> $camelCaseName');
    return iconMap[camelCaseName]!;
  }

  // If not found, log and return a default icon
  debugPrint(
      'Icon not found: "$iconName" (tried: exact, normalized: "$normalizedIconName", camelCase: "$camelCaseName"), using star as fallback');
  return LucideIcons.star;
}

// Helper method to parse color from hex string
Color _parseColor(String colorString, {required Color fallback}) {
  try {
    // Remove any # characters
    String hexColor = colorString.replaceAll('#', '');

    // Handle 3-digit hex codes
    if (hexColor.length == 3) {
      hexColor = hexColor.split('').map((c) => '$c$c').join();
    }

    // Add opacity if needed
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    return Color(int.parse(hexColor, radix: 16));
  } catch (e) {
    debugPrint('Error parsing color $colorString: $e');
    return fallback;
  }
}

Widget _buildSkeletonLoading() {
  return const LoyaltyCardSkeleton(
    itemCount: 5,
  );
}
