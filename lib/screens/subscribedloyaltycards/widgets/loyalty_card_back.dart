import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/models/loyalty_card_model.dart';

class LoyaltyCardBack extends StatelessWidget {
  final LoyaltyCardModel card;
  final Color textColor;

  const LoyaltyCardBack({
    super.key,
    required this.card,
    required this.textColor,
  });

  // Create a subtle noise texture
  Widget _buildNoiseTexture() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: SweepGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  // Create a subtle embossed effect
  Widget _buildEmbossedEdge() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 200, // Match the front card's minimum height
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
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
              color: card.backgroundColor.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Noise texture layer
            _buildNoiseTexture(),
            // Embossed edge
            _buildEmbossedEdge(),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/Image in the center with fixed size
                  if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
                    SizedBox(
                      height: 140, // Fixed height for the logo section
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ), // Reduced bottom margin
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildLogoImage(context),
                          ),
                        ),
                      ),
                    ),
                  // Additional info or terms with minimal height
                  const SizedBox(height: 4), // Reduced spacing
                  SizedBox(
                    height: 32, // Reduced height for the text section
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          'loyalty_cards.swipe_or_tap_to_flip_back'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoImage(BuildContext context) {
    if (card.imageUrl == null || card.imageUrl!.isEmpty) {
      return Icon(Icons.business, size: 48, color: textColor);
    }

    // Check if this is a local file path (starts with file://)
    if (card.imageUrl!.startsWith('file://')) {
      try {
        final filePath = card.imageUrl!.substring(7); // Remove 'file://' prefix
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
      } catch (e) {
        debugPrint('Error loading local image: $e');
        return _buildErrorIcon();
      }
    }

    // For network images
    return CachedNetworkImage(
      imageUrl: card.imageUrl!,
      fit: BoxFit.contain,
      placeholder:
          (context, url) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
      errorWidget: (context, url, error) => _buildErrorIcon(),
    );
  }

  Widget _buildErrorIcon() {
    return Icon(Icons.business, size: 48, color: textColor);
  }
}
