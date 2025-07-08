import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/models/loyalty_card_model.dart' as loyalty_card_model;
import 'package:loyaltyapp/models/search_shop_model.dart' as search_models;
import 'package:loyaltyapp/models/shop_location_model.dart' as shop_location_model;
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/screens/shop_details/shop_details_screen.dart';
import 'package:loyaltyapp/utils/custom_page_route.dart';

class SearchShopCard extends StatelessWidget {
  final search_models.ShopSearchResult shop;
  final Function()? onTap;

  const SearchShopCard({
    Key? key,
    required this.shop,
    this.onTap,
  }) : super(key: key);

  // Helper method to ensure image URL is complete and properly formatted
  List<String> _processImageUrls(dynamic imageData) {
    final List<String> result = [];
    
    if (imageData == null) return result;
    
    // Handle case where imageData is a JSON string array
    if (imageData is String && imageData.trim().startsWith('[')) {
      try {
        // Parse JSON array and extract URLs
        final List<dynamic> urls = jsonDecode(imageData);
        for (var url in urls) {
          if (url is String && url.isNotEmpty) {
            result.add(_ensureFullUrl(url));
          }
        }
      } catch (e) {
        debugPrint('Error parsing image URLs: $e');
      }
    } 
    // Handle case where it's a single URL string
    else if (imageData is String && imageData.isNotEmpty) {
      result.add(_ensureFullUrl(imageData));
    }
    
    return result;
  }
  
  // Ensure URL is complete
  String _ensureFullUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    const baseUrl = 'http://192.168.1.8:8000';
    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  // Convert ShopSearchResult to Shop model for details screen
  Shop _toShopModel() {
    // Process shop images - handle both string and JSON array formats
    final shopImages = _processImageUrls(shop.image);
    
    // Convert ShopSearchResult's loyalty cards to the expected format
    final loyaltyCards = shop.loyaltyCards.isNotEmpty
        ? shop.loyaltyCards.map((card) => loyalty_card_model.LoyaltyCard(
              id: card.id,
              shopId: card.shopId,
              logo: (card.logo != null && card.logo!.isNotEmpty)
                  ? _ensureFullUrl(card.logo!)
                  : '', // Ensure complete URL for logo
              backgroundColor: card.backgroundColor,
              totalStamps: card.totalStamps,
              // Add required fields with default values
              activeStamps: 0,
              isSubscribed: false,
              // Add optional fields
              secondaryColor: null,
              userId: null,
              createdAt: null,
              updatedAt: null,
            )).toList()
        : null;

    // Convert ShopSearchResult's locations to the expected format
    final shopLocations = shop.shopLocations.isNotEmpty
        ? shop.shopLocations.map((loc) => shop_location_model.ShopLocation(
              id: loc.id,
              shopId: loc.shopId,
              lat: loc.lat,
              lng: loc.lng,
              name: loc.name,
            )).toList()
        : null;

    return Shop(
      id: shop.id,
      userId: shop.owner.id,
      categoryId: 0, // Not available in search result
      name: shop.name,
      contactInfo: shop.contactInfo,
      location: shop.location,
      owner: ShopOwner(
        id: shop.owner.id,
        name: shop.owner.name,
        email: shop.owner.email,
        googleId: null, // Not available in search result
        avatar: shop.owner.avatar != null && shop.owner.avatar!.isNotEmpty
          ? _ensureFullUrl(shop.owner.avatar!)
          : null, // Ensure complete URL for avatar
        role: shop.owner.role,
      ),
      category: ShopCategory(
        id: 0, // Not available in search result
        name: shop.categoryName,
        icon: null, // Not available in search result
      ),
      images: shopImages, // Use the processed images list with complete URLs
      loyaltyCards: loyaltyCards,
      shopLocations: shopLocations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double imageSize = 80.0;
    
    // Method to handle shop tap
    void _handleShopTap() {
      // Get the navigator and context before any async operations
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      try {
        final shopModel = _toShopModel();
        debugPrint('🛍️ Navigating to shop: ${shopModel.name} (ID: ${shopModel.id})');
        
        // Call the onTap callback if provided (this will handle overlay dismissal)
        if (onTap != null) {
          onTap!();
        } else {
          // Fallback: Try to close any overlay by popping the current route
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
        
        // Navigate to shop details in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!navigator.mounted) return;
          
          navigator.push(
            CustomPageRoute(
              child: ShopDetailsScreen(
                shop: shopModel,
                shopName: shopModel.name,
                rating: 4.5, // Default rating
                location: shopModel.location ?? 'No location',
                phoneNumber: shopModel.contactInfo ?? 'No contact info',
                images: shopModel.images ?? [],
                category: shopModel.category.name,
                reviewCount: 0,
              ),
              direction: AxisDirection.right,
            ),
          );
        });
      } catch (e, stackTrace) {
        debugPrint('❌ Error in onTap handler: $e');
        debugPrint('Stack trace: $stackTrace');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scaffoldMessenger.mounted) return;
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error opening shop details: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: _handleShopTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shop Image
              _buildImage(theme, imageSize),
              
              const SizedBox(width: 12),
              
              // Shop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shop Name
                    Text(
                      shop.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        shop.categoryName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Location (if available)
                    if (shop.location != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shop.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Loyalty Card Indicator (if available)
                    if (shop.loyaltyCards.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildLoyaltyIndicator(shop.loyaltyCards.first, theme, context),
                    ],
                  ],
                ),
              ),
              
              // Chevron icon
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme, double size) {
    // Try to get loyalty card logo first, then shop image, then owner avatar
    String? imageUrl;
    
    // Check for loyalty card logo
    if (shop.loyaltyCards.isNotEmpty && shop.loyaltyCards.first.logo != null) {
      final logo = shop.loyaltyCards.first.logo!;
      if (logo.isNotEmpty) {
        imageUrl = _ensureFullUrl(logo);
      }
    }
    
    // If no loyalty card logo, try shop image
    if ((imageUrl == null || imageUrl.isEmpty) && shop.image != null) {
      final images = _processImageUrls(shop.image!);
      if (images.isNotEmpty) {
        imageUrl = images.first;
      }
    } 
    
    // If still no image, try owner avatar
    if ((imageUrl == null || imageUrl.isEmpty) && shop.owner.avatar != null) {
      final avatarUrl = _ensureFullUrl(shop.owner.avatar!);
      if (avatarUrl.isNotEmpty) {
        imageUrl = avatarUrl;
      }
    }
    
    // If no image URL, show placeholder icon
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.store_mall_directory_outlined,
          size: size * 0.5,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      );
    }
    
    // Show network image with error handling
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Container(
            width: size,
            height: size,
            color: theme.colorScheme.surfaceVariant,
            child: Icon(
              Icons.broken_image_rounded,
              size: size * 0.4,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: theme.colorScheme.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoyaltyIndicator(search_models.LoyaltyCard card, ThemeData theme, BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          size: 14,
          color: _colorFromHex(card.backgroundColor, context).withOpacity(0.8),
        ),
        const SizedBox(width: 4),
        Text(
          'Loyalty Program • ${card.totalStamps} stamps',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _colorFromHex(String hexColor, BuildContext context) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Theme.of(context).primaryColor; // Use theme color as fallback
    }
  }
}
