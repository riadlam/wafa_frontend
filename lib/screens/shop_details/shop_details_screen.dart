import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:loyaltyapp/hive_models/hive_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart' as ui_model;
import 'package:loyaltyapp/services/loyalty_card_service.dart';
import 'package:loyaltyapp/services/shop_service.dart';
import 'package:loyaltyapp/utils/loyalty_card_converter.dart';
import 'package:loyaltyapp/screens/shop_details/widgets/image_slider.dart';
import 'package:loyaltyapp/screens/shop_details/widgets/shop_header.dart';
import 'package:loyaltyapp/screens/shop_details/widgets/contact_info.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/widgets/loyalty_card_item.dart';
import 'package:loyaltyapp/scalaton_loader/shop_details_skeleton.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Shop shop;
  final String shopName;
  final double rating;
  final String location;
  final String phoneNumber;
  final List<String> images;
  final String category;
  final int reviewCount;

  const ShopDetailsScreen({
    super.key,
    required this.shop,
    required this.shopName,
    required this.rating,
    required this.location,
    required this.phoneNumber,
    required this.images,
    this.category = 'Cafe',
    this.reviewCount = 0,
  });

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  late bool _isFavorite;
  bool _isLoading = true;
  bool _isLoadingLoyaltyCard = true;
  String? _errorMessage;
  ui_model.LoyaltyCardModel? _loyaltyCard;
  final ShopService _shopService = ShopService();

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue; // Default color if none provided
    }
    
    try {
      // Remove any '#' characters and convert to hex
      String hexColor = colorString.replaceAll('#', '');
      
      // Handle both 6-digit and 3-digit hex colors
      if (hexColor.length == 6) {
        hexColor = 'FF' + hexColor; // Add full opacity
      } else if (hexColor.length == 3) {
        hexColor = 'FF' + 
                 hexColor[0] + hexColor[0] + 
                 hexColor[1] + hexColor[1] + 
                 hexColor[2] + hexColor[2];
      }
      
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      print('Error parsing color: $e');
      return Colors.blue; // Default color on error
    }
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = false;
    _loadShopDetails();
    _loadLoyaltyCard();
  }

  Future<void> _loadShopDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // If we already have the shop details from the widget, we can use them
      // Otherwise, fetch them from the API using the shop ID
      if (widget.shop.id > 0) {
        final shop = await _shopService.getShopDetails(widget.shop.id);
        if (shop != null && mounted) {
          // Update the UI with the latest shop details
          // Note: We're not updating the widget.shop directly as it's final
          // Instead, we can use the shop data to update the UI
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading shop details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shop details. Please try again later.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLoyaltyCard() async {
    print('_loadLoyaltyCard called');
    
    if (widget.shop.loyaltyCards == null || widget.shop.loyaltyCards!.isEmpty) {
      print('No loyalty cards found for this shop');
      if (mounted) {
        setState(() {
          _isLoadingLoyaltyCard = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoadingLoyaltyCard = true;
        });
      }

      // Get the shop's loyalty card directly from the shop data
      final shopCard = widget.shop.loyaltyCards!.first;
      print('Using shop loyalty card with ID: ${shopCard.id}');
      
      // Check if we should fetch new loyalty card data
      final shouldFetch = await HiveService.shouldFetchNewShopLoyaltyCard(widget.shop.id);
      
      // Try to get cached loyalty card data first
      if (!shouldFetch) {
        final cachedCard = await HiveService.getCachedShopLoyaltyCard(widget.shop.id);
        if (cachedCard != null && mounted) {
          setState(() {
            _loyaltyCard = ui_model.LoyaltyCardModel(
              id: shopCard.id.toString(),
              name: widget.shop.name,
              description: shopCard.description ?? 'Loyalty Card',
              totalStamps: shopCard.totalStamps,
              earnedStamps: cachedCard['activeStamps'] ?? 0,
              backgroundColor: _parseColor(shopCard.backgroundColor),
              imageUrl: shopCard.logo,
            );
            _isLoadingLoyaltyCard = false;
          });
          return; // Use cached data
        }
      }
      
      // Fetch fresh data from the API
      final loyaltyCardService = LoyaltyCardService();
      final activeStamps = await loyaltyCardService.getActiveStamps(shopCard.id);
      print('Fetched active stamps: $activeStamps');
      
      // Cache the loyalty card data
      await HiveService.saveShopLoyaltyCard(
        widget.shop.id,
        {
          'activeStamps': activeStamps,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
      
      // Update the UI with the fresh data
      if (mounted) {
        setState(() {
          _loyaltyCard = ui_model.LoyaltyCardModel(
            id: shopCard.id.toString(),
            name: widget.shop.name,
            description: shopCard.description ?? 'Loyalty Card',
            totalStamps: shopCard.totalStamps,
            earnedStamps: activeStamps,
            backgroundColor: _parseColor(shopCard.backgroundColor),
            imageUrl: shopCard.logo,
          );
          _isLoadingLoyaltyCard = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading loyalty card: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load loyalty card details';
          _isLoading = false;
        });
      }
    }
  }

  // Directly use the icon name from database
  IconData _getIconFromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) return LucideIcons.star;
    
    // Directly access the icon from LucideIcons using the name from database
    // This assumes the icon name in the database matches the LucideIcons property name exactly
    switch (iconName) {
      case 'perfume': return LucideIcons.sprayCan;
      case 'hair': return LucideIcons.scissors;
      case 'ruler': return LucideIcons.ruler;
      case 'cupSoda': return LucideIcons.cupSoda;
      case 'sandwitch': return LucideIcons.sandwich;

      // Add more icons as needed
      default:
        debugPrint('Icon not found: "$iconName", using star as fallback');
        return LucideIcons.star;
    }
  }

  Widget _buildLoyaltyCardSection() {
    if (_isLoading || _isLoadingLoyaltyCard) {
      return _buildLoadingCard();
    }
    
    if (_errorMessage != null) {
      return _buildErrorCard();
    }
    
    if (_loyaltyCard == null || widget.shop.loyaltyCards == null || widget.shop.loyaltyCards!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Get the loyalty card from the shop
    final loyaltyCard = widget.shop.loyaltyCards!.first;
    
    // Debug log to check the shop category and loyalty card
    debugPrint('Shop category: ${widget.shop.category.name}');
    debugPrint('Loyalty card ID: ${loyaltyCard.id}');
    
    // Get the icon from the shop's category or use a default one
    final iconName = widget.shop.category.icon;
    debugPrint('Icon name from category: $iconName');
    final icon = _getIconFromString(iconName);
    
    return GestureDetector(
      onTap: _handleCardTap,
      child: LoyaltyCardItem(
        card: _loyaltyCard!,
        icon: icon,
      ),
    );
  }
  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  String _getFormattedLocation(String locationJson) {
    try {
      // Try to parse the location as JSON
      final locationData = jsonDecode(locationJson);
      if (locationData is Map && locationData['address'] != null) {
        return locationData['address'] as String;
      }
    } catch (e) {
      // If parsing fails, return the raw location
      return locationJson;
    }
    return locationJson;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
          ? 'favorites.added'.tr() 
          : 'favorites.removed'.tr()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  // Show loading indicator when fetching card details
  Widget _buildLoadingIndicator() {
    return const ShopDetailsSkeleton();
  }

  // Show error message
  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Handle card tap to refresh active stamps
  Future<void> _handleCardTap() async {
    if (_loyaltyCard == null || widget.shop.loyaltyCards == null || widget.shop.loyaltyCards!.isEmpty) return;

    final cardId = widget.shop.loyaltyCards!.first.id;
    final loyaltyCardService = LoyaltyCardService();
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final updatedCard = await loyaltyCardService.getUserLoyaltyCard(cardId);
      
      if (mounted) {
        setState(() {
          _loyaltyCard = LoyaltyCardConverter.toUiModel(updatedCard);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('stamps'.tr(namedArgs: {'count': updatedCard.activeStamps.toString()})),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'error.failed_to_refresh'.tr();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Slider with properly formatted URLs
            ShopImageSlider(
              images: widget.images.map((image) {
                if (image.startsWith('http')) return image;
                // Add base URL if it's a relative path
                final baseUrl = 'http://192.168.1.15:8000';
                return '$baseUrl/${image.replaceAll('\\', '/')}';
              }).toList(),
            ),
            
            // Shop Header with Rating and Social
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
              child: ShopHeader(
                shopName: widget.shopName,
                category: widget.shop.category?.name ?? widget.category,
                heroTag: 'shop-${widget.shopName}',
              ),
            ),
            
            // Loyalty Card Section
            if (widget.shop.loyaltyCards != null && widget.shop.loyaltyCards!.isNotEmpty) ...[
              _buildLoyaltyCardSection(),
              const SizedBox(height: 16.0),
              
              // Description Card - Only show if there's a loyalty card with a description
              if (widget.shop.loyaltyCards != null && 
                  widget.shop.loyaltyCards!.isNotEmpty &&
                  widget.shop.loyaltyCards!.first.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) => Text(
                              'shop_details.description'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.shop.loyaltyCards!.first.description!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
            ],
            
            // Location Information
            if (widget.shop.shopLocations != null && widget.shop.shopLocations!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Increased vertical padding
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) => Text(
                            'shop_details.location'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      
                        const SizedBox(height: 12),
                        ...widget.shop.shopLocations!.map((location) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (location.name.isNotEmpty)
                                Text(
                                  _getFormattedLocation(location.name),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final url = 'https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}';
                                    launchUrl(Uri.parse(url));
                                  },
                                  icon: const Icon(Icons.map),
                                  label: Builder(
                                    builder: (context) => Text('actions.view_on_map'.tr()),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[50],
                                    foregroundColor: Colors.blue[700],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }


}
