import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/models/category_model.dart';
import 'package:loyaltyapp/screens/category_details/category_details_screen.dart';
import 'package:loyaltyapp/services/category_service.dart';
import 'package:loyaltyapp/scalaton_loader/category_grid_skeleton.dart';
import 'package:loyaltyapp/utils/custom_page_route.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoriesGrid extends StatefulWidget {
  const CategoriesGrid({super.key});

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categoriesFuture = Future.value(categories);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'home.error_loading_categories'.tr();
          _isLoading = false;
        });
      }
    }
  }

  // Card styling
  static const Color _textColor =
      Colors.white; // White text for better contrast
  static const Color _iconContainerColor =
      Colors.white24; // Semi-transparent white for icon container
  static const double _cardBorderRadius = 16.0;

  // Gradient colors for cards (applied based on category index % 6)
  // Index 0: Purple to Blue
  // Index 1: Teal to Green
  // Index 2: Pink to Orange
  // Index 3: Dark Blue to Teal
  // Index 4: Orange to Yellow
  // Index 5: Blue to Purple
  final List<List<Color>> _cardGradients = [
    [const Color(0xFF6A11CB), const Color(0xFF2575FC)], // Index 0
    [const Color(0xFFB24592), const Color(0xFFF15F79)], // Index 1
    [const Color(0xFF283E51), const Color(0xFF485563)], // Index 2
    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Index 3
    [const Color(0xFFee0979), const Color(0xFFFF6A00)], // Index 4
    [const Color(0xFF4776E6), const Color(0xFF8E54E9)], // Index 5
  ];

  // Box shadows for depth
  final List<BoxShadow> _cardShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 6),
      spreadRadius: 1,
    ),
  ];

  // Get category subtitle from translations
  String _getCategorySubtitle(int index) {
    try {
      return 'home.category_subtitle_$index'.tr();
    } catch (e) {
      return '';
    }
  }

  // Get category title from translations
  String _getCategoryTitle(int index) {
    try {
      return 'home.category_title_$index'.tr();
    } catch (e) {
      return '';
    }
  }

  // Get full image URL for a category
  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    // Otherwise, construct the full URL
    return 'http://192.168.1.15:8000${imagePath.startsWith('/') ? '' : '/'}$imagePath';
  }

  // Get category icon based on index
  static const List<IconData> _categoryIcons = [
    LucideIcons.sprayCan, // Perfume
    LucideIcons.scissors, // Hair Salon
    LucideIcons.shirt, // Tailoring
    LucideIcons.cupSoda, // Coffee & Drinks
    LucideIcons.sandwich, // Restaurants
  ];

  // Get category icon based on index
  IconData _getCategoryIcon(int index) {
    return _categoryIcons[index % _categoryIcons.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.explore_categories'.tr(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'home.discover_places'.tr(),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const CategoryGridSkeleton(
            itemCount: 6, // Show 6 skeleton items (3 rows of 2)
          ),
        ],
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _loadCategories, child: const Text('Retry')),
          ],
        ),
      );
    }

    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder:
                          (context) => Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                margin: const EdgeInsets.only(right: 12.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                              Text(
                                'home.explore_categories'.tr(),
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'home.discover_places'.tr(),
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const CategoryGridSkeleton(
                itemCount: 6, // Show 6 skeleton items (3 rows of 2)
              ),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Failed to load categories',
                  style: TextStyle(color: Colors.red),
                ),
                TextButton(
                  onPressed: _loadCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final categories = snapshot.data!;

        // Use SingleChildScrollView to handle the entire content
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder:
                          (context) => Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                margin: const EdgeInsets.only(right: 12.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                              Text(
                                'home.explore_categories'.tr(),
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'home.discover_places'.tr(),
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // GridView with fixed height
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    mainAxisExtent:
                        180, // Slightly reduced height for better proportions
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(
                      context,
                      category: categories[index],
                      index: index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        );
      },
    );
  }

  // Build category card widget
  Widget _buildCategoryCard(
    BuildContext context, {
    required Category category,
    required int index,
  }) {
    // Get category subtitle from translations
    final subtitle = _getCategorySubtitle(index);
    // Image URL is no longer used in the current design
    // final String? imageUrl = category.imagePath != null ? _getFullImageUrl(category.imagePath) : null;

    // Get gradient based on index
    final gradient = _cardGradients[index % _cardGradients.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CustomPageRoute(
            child: CategoryDetailsScreen(
              categoryTitle: _getCategoryTitle(index),
              categorySubtitle: subtitle,
              gradient: gradient,
              categoryId: category.id,
            ),
            direction: AxisDirection.right,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          boxShadow: _cardShadows,
        ),
        child: Stack(
          children: [
            // Background pattern or overlay for visual interest
            // Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.1,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         image: DecorationImage(
            //           image: const AssetImage('assets/images/pattern.png'),
            //           fit: BoxFit.cover,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container with subtle background
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: _iconContainerColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(index),
                      size: 28.0,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Category name
                  Text(
                    _getCategoryTitle(index),
                    style: const TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6.0),
                  // Category subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Builder(
                      builder:
                          (context) => Text(
                            _getCategorySubtitle(index),
                            style: TextStyle(
                              color: _textColor.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
}
