import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loyaltyapp/models/category_model.dart';
import 'package:loyaltyapp/screens/category_details/category_details_screen.dart';
import 'package:loyaltyapp/utils/custom_page_route.dart';
import 'package:loyaltyapp/models/search_shop_model.dart';
import 'package:loyaltyapp/services/category_service.dart';
import 'package:loyaltyapp/services/search_service.dart';
import 'package:loyaltyapp/widgets/search_shop_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loyaltyapp/constants/custom_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final CategoryService _categoryService = CategoryService();
  
  // Search state
  Timer? _debounce;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _searchError;
  
  // Results
  List<ShopSearchResult> _searchResults = [];
  
  // Categories state
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
  
  // Recent searches
  final List<String> _recentSearches = [
    'Elbasta shop',
    'hicham cook',
    'pizza',
    '',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final categories = await _categoryService.getCategories();
      
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load categories. Please try again.';
        _isLoading = false;
      });
      print('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    // Assuming your API returns relative paths, prepend the base URL
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return 'http://192.168.1.8:8000${imagePath.startsWith('/') ? '' : '/'}$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search',
        onSearchIconTap: () {
          // Optionally, focus the search field or trigger search logic
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildSearchField(),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for shops...',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _hasSearched = false;
                      _searchResults.clear();
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: (value) {
          _searchShops(value);
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    // Update the query
    _searchQuery = query.trim();
    
    // Cancel previous timer if it was active
    _debounce?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults.clear();
      });
      return;
    }
    
    // Set up debounce
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery.isNotEmpty) {
        _searchShops();
      }
    });
  }
  
  Future<void> _searchShops([String? query]) async {
    final searchQuery = query ?? _searchQuery;
    if (searchQuery.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    
    try {
      final response = await _searchService.searchShops(searchQuery);
      
      if (mounted) {
        setState(() {
          _searchResults = response.data;
          _hasSearched = true;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = e.toString().replaceAll('Exception: ', '');
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show search results if we have searched
    if (_hasSearched) {
      if (_isSearching) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_searchError != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }
      
      if (_searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or check your spelling',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return _buildSearchResults();
    }
    
    // Default content (categories and recent searches)
    return _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentSearchesSection(),
          const SizedBox(height: 24),
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final shop = _searchResults[index];
        return SearchShopCard(
          key: ValueKey('shop_${shop.id}'),
          shop: shop,
        ); // Navigation is handled inside SearchShopCard
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final crossAxisCount = screenWidth > 400 ? 4 : 3; // More columns on larger screens
            final horizontalPadding = 16.0 * 2; // 16px on each side
            final spacing = 12.0; // Space between items
            final availableWidth = screenWidth - horizontalPadding - (spacing * (crossAxisCount - 1));
            final itemSize = availableWidth / crossAxisCount;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 0.75, // Slightly wider than tall
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(_categories[index], itemSize);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map((search) => _buildChip(search, Theme.of(context)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        // Trigger search
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  // Static data for category appearance (same as in CategoriesGrid)
  final List<Map<String, dynamic>> _categoryAppearance = [
    {
      'subtitle': 'Fine Dining',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'subtitle': 'Coffee & Tea',
      'icon': Icons.coffee,
      'color': const Color(0xFF6A4C93),
    },
    {
      'subtitle': 'Italian Cuisine',
      'icon': Icons.local_pizza,
      'color': const Color(0xFFFFA726),
    },
    {
      'subtitle': 'American Classics',
      'icon': Icons.fastfood,
      'color': const Color(0xFF4ECDC4),
    },
    {
      'subtitle': 'Japanese Delights',
      'icon': Icons.rice_bowl,
      'color': const Color(0xFF45B7D1),
    },
    {
      'subtitle': 'Desserts & More',
      'icon': Icons.cake,
      'color': const Color(0xFFA78BFA),
    },
  ];

  // Get appearance data for a category by index
  Map<String, dynamic> _getCategoryAppearance(int index) {
    // Use absolute value to ensure positive index, then get the remainder
    return _categoryAppearance[index.abs() % _categoryAppearance.length];
  }

  Widget _buildCategoryItem(Category category, double itemSize) {
    final imageUrl = _getFullImageUrl(category.imagePath);
    // Calculate sizes based on the item size
    final imageSize = itemSize * 0.9; // 90% of item width for the image
    final textHeight = 40.0; // Fixed height for text
    final padding = 4.0; // Internal padding
    
    // Get appearance data for this category
    // Use category.id if available, otherwise hash the category name to get a consistent index
    final categoryIndex = category.id ?? category.name.hashCode;
    final appearance = _getCategoryAppearance(categoryIndex);
    final color = appearance['color'] as Color;
    final subtitle = appearance['subtitle'] as String;
    
    return Container(
      width: itemSize,
      padding: EdgeInsets.all(padding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              CustomPageRoute(
                child: CategoryDetailsScreen(
                  categoryTitle: category.name,
                  categorySubtitle: subtitle,
                  gradient: [color, color.withOpacity(0.8)],
                  categoryId: category.id,
                ),
                direction: AxisDirection.right,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image container
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? imageUrl.endsWith('.svg')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SvgPicture.network(
                              imageUrl,
                              width: imageSize,
                              height: imageSize,
                              placeholderBuilder: (BuildContext context) => Container(
                                padding: const EdgeInsets.all(30.0),
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.error_outline,
                                size: imageSize * 0.5,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          )
                    : Icon(
                        Icons.category_outlined,
                        size: imageSize * 0.5,
                        color: Theme.of(context).hintColor,
                      ),
              ),
              const SizedBox(height: 8),
              // Text container
              SizedBox(
                height: textHeight,
                child: Center(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories title skeleton
          Container(
            width: 120,
            height: 24,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Grid skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 8, // Show 8 skeleton items
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}