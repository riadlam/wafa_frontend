import 'package:flutter/material.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/widgets/loyalty_card_item.dart';
import 'package:loyaltyapp/services/loyalty_card_service.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/providers/loyalty_card_provider.dart';

class LoyaltyCardDisplay extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? cardMargin;
  
  const LoyaltyCardDisplay({
    super.key,
    this.padding,
    this.cardMargin,
  });

  @override
  State<LoyaltyCardDisplay> createState() => _LoyaltyCardDisplayState();
}

  // Helper method to parse color from hex string
  Color _parseColor(String colorString, {required Color fallback}) {
    try {
      if (colorString.startsWith('#')) {
        final hexCode = colorString.replaceAll('#', '');
        if (hexCode.length == 6 || hexCode.length == 8) {
          return Color(int.parse('FF$hexCode', radix: 16));
        } else if (hexCode.length == 3) {
          // Handle 3-digit hex codes
          final fullHex = 'FF${hexCode[0]}${hexCode[0]}${hexCode[1]}${hexCode[1]}${hexCode[2]}${hexCode[2]}';
          return Color(int.parse(fullHex, radix: 16));
        }
      }
      return fallback;
    } catch (e) {
      debugPrint('Error parsing color "$colorString": $e');
      return fallback;
    }
  }

class _LoyaltyCardDisplayState extends State<LoyaltyCardDisplay> {
  bool _isLoading = true;
  List<LoyaltyCardModel> _loyaltyCards = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load cards if not already loaded by the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LoyaltyCardProvider>(context, listen: false);
      if (provider.shopName == null) {
        _loadLoyaltyCards();
      } else {
        // If provider already has data, use it
        setState(() {
          _isLoading = false;
          _error = null;
        });
      }
    });
  }

  Future<void> _loadLoyaltyCards() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('1. Starting to load loyalty cards...');
      final loyaltyCardService = LoyaltyCardService();
      
      debugPrint('2. Calling getMyShopLoyaltyCards()...');
      final shopCards = await loyaltyCardService.getMyShopLoyaltyCards();
      debugPrint('3. Received ${shopCards.length} shop cards');
      
      if (shopCards.isEmpty) {
        debugPrint('No shop cards found');
        setState(() {
          _isLoading = false;
          _error = 'No loyalty cards found';
        });
        return;
      }
      
      debugPrint('4. Processing shop cards...');
      final cards = <LoyaltyCardModel>[];
      
      for (final shop in shopCards) {
        try {
          debugPrint('5. Processing shop: ${shop.name}');
          debugPrint('   - Shop has ${shop.loyaltyCards.length} loyalty cards');
          
          for (final card in shop.loyaltyCards) {
            try {
              debugPrint('6. Processing card ID: ${card.id}');
              
              // Log all available properties on the card object
              debugPrint('   - Card properties:');
              debugPrint('     - id: ${card.id}');
              debugPrint('     - logo: ${card.logo}');
              debugPrint('     - backgroundColor: ${card.backgroundColor}');
              debugPrint('     - totalStamps: ${card.totalStamps}');
              debugPrint('     - activeStamps: ${card.activeStamps}');
              
              // Get the logo URL from the card model
              final logoUrl = card.logo.isNotEmpty 
                  ? card.logo 
                  : 'https://via.placeholder.com/100';
                  
              debugPrint('   - Using logo URL: $logoUrl');
              
              // Validate the URL format
              if (!Uri.tryParse(logoUrl)!.hasAbsolutePath) {
                debugPrint('   - Invalid URL format: $logoUrl');
              }
              debugPrint('   - Final logo URL: $logoUrl');
              
              // Create the card model
              final cardModel = LoyaltyCardModel(
                id: card.id.toString(),
                name: shop.name,
                description: 'Loyalty Card',
                totalStamps: card.totalStamps,
                earnedStamps: card.activeStamps ?? 0,
                isSubscribed: true,
                imageUrl: logoUrl,
                backgroundColor: _parseColor(card.backgroundColor, fallback: const Color(0xFF6C63FF)),
                textColor: Colors.white,
                stampColor: Colors.white.withOpacity(0.6),
                stampFillColor: Colors.white,
              );
              
              cards.add(cardModel);
              debugPrint('   - Successfully created card model');
              
            } catch (cardError, cardStack) {
              debugPrint('   - Error processing card: $cardError');
              debugPrint('   - Card stack trace: $cardStack');
            }
          }
        } catch (shopError, shopStack) {
          debugPrint('Error processing shop ${shop.id}: $shopError');
          debugPrint('Shop stack trace: $shopStack');
        }
      }

      if (mounted) {
        debugPrint('7. Loaded ${cards.length} valid loyalty cards');
        if (cards.isEmpty) {
          debugPrint('8. No valid cards could be loaded');
          setState(() {
            _error = 'No valid loyalty cards found';
            _isLoading = false;
          });
        } else {
          debugPrint('8. Successfully loaded ${cards.length} cards');
          setState(() {
            _loyaltyCards = cards;
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('FATAL ERROR loading loyalty cards: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = 'Failed to load loyalty cards: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoyaltyCardProvider>(context);
    
    // Show loading if local state is loading
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if local state has error
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // If no cards in local state and provider doesn't have data, show empty state
    if (_loyaltyCards.isEmpty && (provider.shopName == null || provider.shopName!.isEmpty)) {
      return const SizedBox.shrink();
    }
    
    // Use provider data if available, otherwise fall back to local state
    final card = provider.shopName != null && provider.shopName!.isNotEmpty
        ? LoyaltyCardModel(
            id: '1', // This should come from provider if available
            name: provider.shopName!,
            totalStamps: provider.totalStamps,
            earnedStamps: 0, // This should come from provider if available
            imageUrl: provider.logoUrl,
            backgroundColor: provider.cardColor,
          )
        : _loyaltyCards.isNotEmpty ? _loyaltyCards.first : null;
        
    if (card == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Padding(
        padding: widget.cardMargin ?? EdgeInsets.zero,
        child: LoyaltyCardItem(
          card: card,
          stampsPerRow: 5,
        ),
      ),
    );
  }
}
