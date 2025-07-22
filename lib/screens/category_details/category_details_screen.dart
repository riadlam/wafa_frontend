import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:loyaltyapp/models/shop_model.dart';
import 'package:loyaltyapp/services/category_service.dart';
import 'package:loyaltyapp/screens/category_details/widgets/category_banner.dart';
import 'package:loyaltyapp/screens/category_details/widgets/place_card.dart';
import 'package:loyaltyapp/scalaton_loader/place_card_skeleton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:loyaltyapp/constants/algerian_wilayas.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryTitle;
  final String categorySubtitle;
  final List<Color> gradient;
  final int categoryId;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryTitle,
    required this.categorySubtitle,
    required this.gradient,
    required this.categoryId,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

enum ShopSortOption { nearestFirst, farthestFirst, aToZ, zToA }

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Shop>> _shopsFuture;
  bool _isLoading = true;
  String? _error;
  ShopSortOption _currentSortOption = ShopSortOption.nearestFirst;
  String? _selectedWilaya;
  bool _isFilteringByWilaya = false;
  final GlobalKey _filterKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showWilayaMenu() {
    final renderBox =
        _filterKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    // Remove any existing overlay
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height + 4,
                  width: 200,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'select_wilaya'.tr(),
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: algerianWilayas.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return ListTile(
                                    title: Text('all_wilayas'.tr()),
                                    onTap: () {
                                      setState(() {
                                        _selectedWilaya = null;
                                        _isFilteringByWilaya = false;
                                      });
                                      _loadShops(wilaya: null);
                                      _removeOverlay();
                                    },
                                    tileColor:
                                        _selectedWilaya == null
                                            ? Colors.grey[200]
                                            : null,
                                  );
                                }
                                final wilaya = algerianWilayas[index - 1];
                                return ListTile(
                                  title: Text(wilaya['name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedWilaya = wilaya['name'];
                                      _isFilteringByWilaya = true;
                                    });
                                    _loadShops(wilaya: wilaya['name']);
                                    _removeOverlay();
                                  },
                                  tileColor:
                                      _selectedWilaya == wilaya['name']
                                          ? Colors.grey[200]
                                          : null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  Future<void> _loadShops({String? wilaya}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Shop> shops;
      if (wilaya != null && wilaya.isNotEmpty) {
        shops = await _categoryService.getShopsByWilayaAndCategory(
          widget.categoryId,
          wilaya,
        );
        _isFilteringByWilaya = true;
      } else {
        shops = await _categoryService.getShopsByCategory(widget.categoryId);
        _isFilteringByWilaya = false;
      }

      setState(() {
        _shopsFuture = Future.value(shops);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error.failed_to_load'.tr();
        _isLoading = false;
      });
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isFilteringByWilaya && _selectedWilaya != null)
                        Text(
                          'filtered_by'.tr(namedArgs: {'wilaya': _selectedWilaya ?? ''}),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                ...ShopSortOption.values.map((option) {
                  return ListTile(
                    title: Text(
                      _getSortOptionText(option),
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                    trailing:
                        _currentSortOption == option
                            ? Icon(Icons.check, color: widget.gradient.last)
                            : null,
                    onTap: () {
                      setState(() {
                        _currentSortOption = option;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
    );
  }

  String _getSortOptionText(ShopSortOption option) {
    switch (option) {
      case ShopSortOption.nearestFirst:
        return 'sort_options.nearest_first'.tr();
      case ShopSortOption.farthestFirst:
        return 'sort_options.farthest_first'.tr();
      case ShopSortOption.aToZ:
        return 'sort_options.a_to_z'.tr();
      case ShopSortOption.zToA:
        return 'sort_options.z_to_a'.tr();
    }
  }

  List<Shop> _sortShops(List<Shop> shops) {
    switch (_currentSortOption) {
      case ShopSortOption.nearestFirst:
        return List.from(shops)..sort((a, b) {
          // This is a simplified sort - you'll need to implement actual distance calculation
          // based on user's current location and shop location
          return 0;
        });
      case ShopSortOption.farthestFirst:
        return List.from(shops)..sort((a, b) {
          // Reverse of nearest first
          return 0;
        });
      case ShopSortOption.aToZ:
        return List.from(shops)..sort((a, b) => a.name.compareTo(b.name));
      case ShopSortOption.zToA:
        return List.from(shops)..sort((a, b) => b.name.compareTo(a.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 160.0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  // Sort Button
                  IconButton(
                    icon: const Icon(Icons.sort, color: Colors.white),
                    onPressed: _showSortOptions,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: CategoryBanner(
                    title: widget.categoryTitle,
                    subtitle: widget.categorySubtitle,
                    gradient: widget.gradient,
                  ),
                ),
              ),
            ],
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const PlaceCardSkeleton(itemCount: 4);
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadShops,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.gradient.last,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text('actions.try_again'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<List<Shop>>(
      future: _shopsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PlaceCardSkeleton(itemCount: 4);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'error.no_shops_available'.tr(),
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        List<Shop> shops = _sortShops(snapshot.data!);
        if (shops.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'error.no_shops_found'.tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton.outlined(
                      onPressed: () {
                        // Your onPressed logic
                      },
                      icon: Icon(
                        LucideIcons.filter,
                        color: Colors.black87,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        side: BorderSide(color: Colors.black54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const Spacer(),
                    // Wilaya Filter Dropdown
                    Container(
                      key: _filterKey,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: _showWilayaMenu,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedWilaya ?? 'actions.filter_by_wilaya'.tr(),
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final shop = shops[index];
                  final baseUrl = 'http://192.168.1.15:8000';
                  final String imageUrl;

                  if (shop.images?.isNotEmpty == true) {
                    imageUrl =
                        '$baseUrl/${shop.images!.first.replaceAll('\\', '/')}';
                  } else if (shop.owner.avatar?.startsWith('http') == true) {
                    imageUrl = shop.owner.avatar!;
                  } else if (shop.owner.avatar != null) {
                    imageUrl =
                        '$baseUrl/${shop.owner.avatar!.replaceAll('\\', '/')}';
                  } else {
                    imageUrl = 'https://via.placeholder.com/150';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PlaceCard(shop: shop, imageUrl: imageUrl),
                  );
                }, childCount: shops.length),
              ),
            ),
          ],
        );
      },
    );
  }
}
