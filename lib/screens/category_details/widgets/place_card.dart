import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/screens/shop_details/shop_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loyaltyapp/widgets/distance_badge.dart';
import 'package:loyaltyapp/utils/location_utils.dart' as location_utils;
import 'package:loyaltyapp/utils/custom_page_route.dart';

class PlaceCard extends StatefulWidget {
  final Shop shop;
  final String imageUrl;

  const PlaceCard({
    super.key,
    required this.shop,
    required this.imageUrl,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  late final Future<String?> _distanceFuture;
  
  String _getFormattedLocation() {
    try {
      // First try to get from shopLocations if available
      if (widget.shop.shopLocations?.isNotEmpty == true) {
        final location = widget.shop.shopLocations!.first;
        try {
          // Try to parse the location name as JSON
          final locationData = jsonDecode(location.name);
          if (locationData is Map && locationData['address'] != null) {
            return locationData['address'] as String;
          }
        } catch (e) {
          // If parsing fails, return the raw name
          return location.name;
        }
        return location.name;
      }
      
      // Fallback to shop.location
      if (widget.shop.location != null) {
        try {
          // Try to parse the location as JSON
          final locationData = jsonDecode(widget.shop.location!);
          if (locationData is Map && locationData['address'] != null) {
            return locationData['address'] as String;
          }
        } catch (e) {
          // If parsing fails, return the raw location
          return widget.shop.location!;
        }
      }
      
      return 'No location';
    } catch (e) {
      return 'Location unavailable';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    if (widget.shop.shopLocations?.isNotEmpty == true) {
      final location = widget.shop.shopLocations!.first;
      _distanceFuture = location_utils.LocationUtils.getFormattedDistance(
        location.lat,
        location.lng,
      );
    }
  }

  void _navigateToShopDetails(BuildContext context) {
    Navigator.of(context).push(
      CustomPageRoute(
        child: ShopDetailsScreen(
          shop: widget.shop,
          shopName: widget.shop.name,
          rating: 4.5, // Default rating
          location: widget.shop.location ?? 'No location provided',
          phoneNumber: widget.shop.contactInfo ?? 'No contact info',
          images: widget.shop.images?.isNotEmpty == true 
              ? widget.shop.images! 
              : [widget.imageUrl],
          category: widget.shop.category.name,
        ),
        direction: AxisDirection.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToShopDetails(context),
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Main image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Distance badge
            if (widget.shop.shopLocations?.isNotEmpty == true)
              Positioned(
                top: 12,
                right: 12,
                child: FutureBuilder<String?>(
                  future: _distanceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return DistanceBadge(distance: snapshot.data!);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            
            // Dark overlay for better text visibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content (name and location)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.shop.name,
                    style: GoogleFonts.roboto(
                      color: Colors.white,                    
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 14.0,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          _getFormattedLocation(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Share button with image asset
            Positioned(
              bottom: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share this place!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/sharebutton.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
