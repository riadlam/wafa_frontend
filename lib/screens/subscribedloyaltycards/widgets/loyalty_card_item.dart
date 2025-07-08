import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'tilt_card.dart';
import 'flip_card_widget.dart';
import 'loyalty_card_back.dart';

// Extension to handle null-safe host access
extension UriExtension on Uri? {
  String? get hostOrNull => this?.host;
}

class LoyaltyCardItem extends StatelessWidget {
  final LoyaltyCardModel card;
  final int stampsPerRow;
  final IconData? icon;

  LoyaltyCardItem({
    super.key,
    required this.card,
    this.stampsPerRow = 5,
    this.icon,
  }) {
    // Debug log to check the icon being passed
    debugPrint('LoyaltyCardItem created with icon: ${icon?.toString() ?? 'null'}');
  }

  // Try to load the image with proper handling for both network and local files
  Widget _buildLogoWidget(LoyaltyCardModel card) {
    if (card.imageUrl == null || card.imageUrl!.isEmpty) {
      debugPrint('Image URL is null or empty');
      return _buildErrorWidget();
    }

    debugPrint('Trying to load image from: ${card.imageUrl}');
    
    // Check if this is a local file path (starts with file://)
    if (card.imageUrl!.startsWith('file://')) {
      try {
        final filePath = card.imageUrl!.substring(7); // Remove 'file://' prefix
        return Image.file(
          File(filePath),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading local image: $error');
            return _buildErrorWidget();
          },
        );
      } catch (e) {
        debugPrint('Error loading local image: $e');
        return _buildErrorWidget();
      }
    }

    // Parse the URI to check if it's a valid URL
    final uri = Uri.tryParse(card.imageUrl!);
    if (uri == null) {
      debugPrint('Failed to parse image URL: ${card.imageUrl}');
      return _buildErrorWidget();
    }

    final isExternalImage = uri.hostOrNull != null &&
        !uri.hostOrNull!.endsWith('yourdomain.com') &&
        (uri.scheme == 'http' || uri.scheme == 'https');
        
    debugPrint('Is external image: $isExternalImage');

    if (isExternalImage) {
      // For external images, try to load with headers first
      return CachedNetworkImage(
        imageUrl: card.imageUrl!,
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Referer': 'https://your-app.com/'
        },
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          debugPrint('Error loading external image: $error');
          return _buildErrorWidget();
        },
      );
    }

    // For internal network images
    return CachedNetworkImage(
      imageUrl: card.imageUrl!,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[200],
      child: Icon(Icons.image, color: Colors.grey[400]),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[200],
      child: const Icon(
        Icons.restaurant,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  // Create a subtle border highlight
  Widget _buildBorderHighlight() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  // Create a subtle shine effect
  Widget _buildShineEffect() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(-0.9, -0.9),
            end: Alignment(0.9, 0.9),
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.transparent,
              Colors.white.withOpacity(0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontFace() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200, // Match the back card's minimum height
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            card.backgroundColor,
            card.secondaryColor ?? card.backgroundColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0.5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine effect
          _buildShineEffect(),
          // Border highlight
          _buildBorderHighlight(),
          // Main content
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // Left Mascot/Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildLogoWidget(card),
                          )
                        : Icon(
                            card.icon ?? Icons.card_membership,
                            size: 48,
                            color: card.textColor,
                          ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right content with name + stamps - Reduced padding for more space
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: card.textColor,
                            shadows: [
                              Shadow(
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1.0,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6), // Reduced spacing
                        // Stamps Grid - Made more compact
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: stampsPerRow,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                            mainAxisExtent: 48,  // Slightly larger to accommodate the circle
                          ),
                          itemCount: card.totalStamps,
                          itemBuilder: (context, index) {
                            final isFilled = index < card.earnedStamps;
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isFilled ? Colors.transparent : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: card.stampColor,
                                  width:1.0,
                                ),
                                boxShadow: [
                                  if (!isFilled)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isFilled
                                    ? Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white, // Slightly transparent stamp color
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: card.stampColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            // Use the card's icon for the stamp, fallback to the widget's icon, then to sparkles
                                            final currentIcon = card.icon ?? icon ?? LucideIcons.sparkles;
                                            debugPrint('Rendering stamp with icon: ${currentIcon.toString()}');
                                            return Icon(
                                              currentIcon,
                                              color: Colors.black, // Use the card's stamp fill color
                                              size: 28, // Slightly smaller to fit better in the circle
                                            );
                                          },
                                        ),
                                      )
                                    : null,
                              ),

                            );
                          },
                        ),
                        const SizedBox(height: 6),  // Reduced spacing
                        Text(
                          '${card.earnedStamps} of ${card.totalStamps} stamps',
                          style: TextStyle(
                            fontSize: 12,  // Slightly smaller font
                            color: card.textColor.withOpacity(0.95),
                            fontWeight: FontWeight.w700,  // Slightly bolder
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),  // Reduced spacing
                        Text(
                          'Tap to flip',
                          style: TextStyle(
                            fontSize: 10,
                            color: card.textColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),) 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Create a floating shadow widget with smooth animation
  Widget _buildFloatingShadow() {
    return Positioned(
      bottom: 2,
      left: 0,
      right: 0,
      height: 16,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 2 * math.pi),
        duration: const Duration(seconds: 3),
        builder: (context, value, child) {
          // Create a subtle pulsing effect using sine wave
          final scale = 0.9 + 0.1 * (math.sin(value) + 1) / 2;
          final opacity = 0.08 + 0.04 * (math.sin(value) + 1) / 2;
          
          return Transform.scale(
            scaleX: scale,
            scaleY: scale * 0.4, // Very flat shadow
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Floating shadow
            _buildFloatingShadow(),
            // The card with tilt and flip effects
            TiltCard(
              maxTilt: 0.03,
              maxRotation: 0.2,
              perspective: 0.001,
              child: FlipCardWidget(
                front: _buildFrontFace(),
                back: LoyaltyCardBack(
                  card: card,
                  textColor: card.textColor,
                ),
                duration: const Duration(milliseconds: 600),
              ),
            ),
          ],
        ),
      ),
    ).animate(
      effects: [
        FadeEffect(
          duration: 300.ms,
          curve: Curves.easeOutQuad,
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        ),
      ],
    );
  }
}
