import 'package:flutter/material.dart';
import 'package:motorix_app/logic/filtering_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_preview.dart';

class InfiniteGrid extends StatefulWidget {
  const InfiniteGrid({super.key});

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid> {
  static const _scrollThreshold = 200.0;
  static const _largeScreenWidth = 1000.0;
  static const _mediumScreenWidth = 600.0;
  static const _itemSpacing = 6.0;
  static const _itemRunSpacing = 16.0;
  static const _gridPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const _loadingPadding = EdgeInsets.all(16);
  static const _initTimeout = Duration(seconds: 5);

  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeListings();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final provider = context.read<ListingsProvider>();
    final position = _scrollController.position;
    final isNearBottom =
        position.pixels >= position.maxScrollExtent - _scrollThreshold;

    if (isNearBottom && provider.canLoadMore && !provider.isLoading) {
      provider.getMoreListings();
    }
  }

  Future<void> _initializeListings() async {
    if (_hasInitialized || !mounted) return;
    _hasInitialized = true;

    try {
      final filteringProvider = context.read<FilteringProvider>();
      final listingsProvider = context.read<ListingsProvider>();

      await _waitForAttributes(filteringProvider).timeout(
        _initTimeout,
        onTimeout: () {
          // Timeout waiting for listing attributes
        },
      );

      if (!mounted) return;

      // Only initialize filters if they haven't been set yet
      // This preserves default filters (like location) that were set before page load
      if (listingsProvider.equalFilters.isEmpty) {
        listingsProvider.equalFilters = Map.from(
          filteringProvider.selectedEqualFilters,
        );
      }

      // Fetch listings
      await listingsProvider.getNewListings();
    } catch (e) {
      if (mounted) {
        // TODO: Show error state to user
      }
    }
  }

  Future<void> _waitForAttributes(FilteringProvider provider) async {
    while (provider.listingAttributeOptions.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  int _getCrossAxisCount(double width) {
    if (width > _largeScreenWidth) return 4;
    if (width > _mediumScreenWidth) return 3;
    return 2;
  }

  double _calculateItemWidth(double screenWidth, int crossAxisCount) {
    final horizontalPadding = _gridPadding.horizontal;
    final totalSpacing =
        horizontalPadding + (_itemSpacing * (crossAxisCount - 1));
    return (screenWidth - totalSpacing) / crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final itemWidth = _calculateItemWidth(screenWidth, crossAxisCount);

    // Handle empty state
    if (provider.listings.isEmpty && !provider.isLoading) {
      return Center(
        child: Text(
          'No listings found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: _gridPadding,
      children: [
        Wrap(
          spacing: _itemSpacing,
          runSpacing: _itemRunSpacing,
          alignment: WrapAlignment.start,
          children: List.generate(
            provider.listings.length,
            (index) => ListingPreview(
              width: itemWidth,
              listing: provider.listings[index],
            ),
          ),
        ),
        if (provider.isLoading)
          const Padding(
            padding: _loadingPadding,
            child: Center(child: CircularProgressIndicator()),
          ),
        // End of listings indicator
        if (!provider.canLoadMore &&
            !provider.isLoading &&
            provider.listings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  "You've reached the end",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing all ${provider.totalListings} listing${provider.totalListings == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 64),
              ],
            ),
          ),
      ],
    );
  }
}
