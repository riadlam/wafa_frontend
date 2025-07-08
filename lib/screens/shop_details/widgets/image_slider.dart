import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class ShopImageSlider extends StatefulWidget {
  final List<String> images;
  final double height;
  final BorderRadius? borderRadius;

  const ShopImageSlider({
    super.key,
    required this.images,
    this.height = 320,
    this.borderRadius,
  });

  @override
  State<ShopImageSlider> createState() => _ShopImageSliderState();
}

class _ShopImageSliderState extends State<ShopImageSlider> {
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  bool _isUserScrolling = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isUserScrolling && widget.images.length > 1) {
        final nextPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Main Image Slider
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isUserScrolling = true;
              } else if (notification is ScrollEndNotification) {
                _isUserScrolling = false;
                _startAutoSlide();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'shop-image-$index',
                  child: ClipRRect(
                    borderRadius: widget.borderRadius ?? BorderRadius.zero,
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? Colors.grey[900] : Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Back Button with Glass Morphism
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: _GlassMorphicContainer(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),

        // Like Button with Glass Morphism
        if (widget.images.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _GlassMorphicContainer(
              child: ValueListenableBuilder<bool>(
                valueListenable: ValueNotifier<bool>(false),
                builder: (context, isLiked, _) {
                  return IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      // Handle like action
                    },
                  );
                },
              ),
            ),
          ),

        // Page Indicator with Glass Morphism
        if (widget.images.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: _GlassMorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                    widget.images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _currentPage == index ? 24.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassMorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurRadius;
  final double spreadRadius;
  final Color color;

  const _GlassMorphicContainer({
    required this.child,
    this.padding,
    this.borderRadius = 12.0,
    this.blurRadius = 10.0,
    this.spreadRadius = 0,
    this.color = const Color(0x1A000000),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurRadius * 0.5,
          sigmaY: blurRadius * 0.5,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: blurRadius,
                spreadRadius: spreadRadius,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
