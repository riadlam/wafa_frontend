import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/models/search_shop_model.dart';
import 'package:loyaltyapp/services/search_service.dart';
import 'package:loyaltyapp/widgets/search_shop_card.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final bool enableSearch;
  final VoidCallback? onSearchIconTap;

  const SearchAppBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.title,
    this.enableSearch = true,
    this.onSearchIconTap,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SearchService _searchService = SearchService();
  Timer? _debounce;
  
  List<ShopSearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _searchError;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSearchResults() {
    _removeOverlay();
    
    if (!_isSearching || _searchController.text.trim().isEmpty) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildSearchResults(),
          ),
        ),
      ),
    );

    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _onSearchChanged(String query) {
    if (!_isSearching) {
      setState(() => _isSearching = true);
    }
    
    // Show loading indicator immediately
    if (query.trim().isNotEmpty) {
      setState(() {
        _isLoading = true;
        _searchError = null;
      });
    } else {
      setState(() {
        _searchResults = [];
        _searchError = null;
        _isLoading = false;
      });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchError = null;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await _searchService.searchShops(query);
      
      if (mounted) {
        setState(() {
          _searchResults = response.data;  // Access the data property of the response
          _searchError = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = 'Failed to load search results: ${e.toString()}';
          _isLoading = false;
        });
      }
      debugPrint('Search error: $e');
    }
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No results found'),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final shop = _searchResults[index];
            return SearchShopCard(
              shop: shop,
              onTap: _dismissSearch, // Pass dismiss function to SearchShopCard
            );
          },
        ),
      ],
    );
  }

  void _dismissSearch() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isSearching = false;
    _searchController.clear();
    _searchResults = [];
    _searchFocusNode.unfocus();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() async {
        if (_isSearching) {
          setState(_dismissSearch);
          return false;
        }
        return true;
      });
    });

    return WillPopScope(
      onWillPop: () async {
        if (_isSearching) {
          setState(_dismissSearch);
          return false;
        }
        return true;
      },
      child: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search shops...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: _onSearchChanged,
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.title ?? 'Explore',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 38.4, // 20% larger than 32
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (widget.enableSearch)
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.black,
                size: 36, // 20% larger than default 30
              ),
              onPressed: () {
                if (!_isSearching) {
                  if (widget.onSearchIconTap != null) {
                    widget.onSearchIconTap!();
                  }
                } else {
                  setState(() {
                    _dismissSearch();
                  });
                }
              },
            ),
        ],
      ),
    );
  }
}
