import 'package:flutter/material.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_empty_state.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/presentation/widgets/listing/listing_preview.dart';

class _SkeletonCard extends StatelessWidget {
  final double width;
  final Animation<double> shimmer;

  const _SkeletonCard({required this.width, required this.shimmer});

  Widget _shimmerLine({required double height, double radius = 4, double endFraction = 1.0}) {
    return Row(
      children: [
        Expanded(
          flex: (endFraction * 100).round(),
          child: AnimatedBuilder(
            animation: shimmer,
            builder: (context, _) {
              return Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Color.lerp(
                    const Color(0xFFEFE9E6),
                    const Color(0xFFE0D5D0),
                    shimmer.value,
                  ),
                ),
              );
            },
          ),
        ),
        if (endFraction < 1.0)
          Spacer(flex: ((1.0 - endFraction) * 100).round()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: shimmer,
              builder: (context, _) {
                return AspectRatio(
                  aspectRatio: AppConstants.listingImageAspectRatio,
                  child: Container(
                    color: Color.lerp(
                      const Color(0xFFEFE9E6),
                      const Color(0xFFE0D5D0),
                      shimmer.value,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(height: 13, endFraction: 0.75),
                const SizedBox(height: 6),
                _shimmerLine(height: 11, endFraction: 0.55),
                const SizedBox(height: 8),
                _shimmerLine(height: 11, endFraction: 0.45),
                const SizedBox(height: 8),
                _shimmerLine(height: 14, endFraction: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfiniteGrid extends StatefulWidget {
  const InfiniteGrid({super.key});

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid>
    with TickerProviderStateMixin {
  static const _scrollThreshold = 200.0;
  static const _largeScreenWidth = 1000.0;
  static const _mediumScreenWidth = 600.0;
  static const _itemSpacing = 10.0;
  static const _itemRunSpacing = 16.0;
  static const _gridPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const _loadingPadding = EdgeInsets.all(16);
  static const _initTimeout = Duration(seconds: 5);

  final ScrollController _scrollController = ScrollController();
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeListings();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
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

      if (listingsProvider.equalFilters.isEmpty) {
        listingsProvider.equalFilters = Map.from(
          filteringProvider.selectedEqualFilters,
        );
      }

      await listingsProvider.getNewListings();
    } catch (e) {
      // getNewListings() already catches its own fetch errors into
      // ListingsProvider.errorMessage (rendered via _buildErrorState below);
      // this only catches _waitForAttributes failing outright.
      debugPrint('⚠️ Failed to initialize listings: $e');
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

  Widget _buildSkeletonGrid(int crossAxisCount, double itemWidth) {
    return ListView(
      padding: _gridPadding,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Wrap(
          spacing: _itemSpacing,
          runSpacing: _itemRunSpacing,
          children: List.generate(
            crossAxisCount * 3,
            (_) => _SkeletonCard(width: itemWidth, shimmer: _shimmerAnimation),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.checkroom_outlined,
      title: 'No dresses found',
      body: 'Try adjusting your filters or search terms.',
    );
  }

  Widget _buildErrorState(ListingsProvider provider) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      body: provider.errorMessage,
      action: FilledButton(
        onPressed: provider.getNewListings,
        child: const Text('Try again'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final itemWidth = _calculateItemWidth(screenWidth, crossAxisCount);

    // Skeleton grid during initial load
    if (provider.listings.isEmpty && provider.isLoading) {
      return _buildSkeletonGrid(crossAxisCount, itemWidth);
    }

    // Error state — a failed fetch is not the same as a genuine zero
    // results, and must not be presented as "adjust your filters"
    if (provider.listings.isEmpty && provider.hasError) {
      return _buildErrorState(provider);
    }

    // Empty state
    if (provider.listings.isEmpty) {
      return _buildEmptyState();
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
        if (!provider.canLoadMore &&
            !provider.isLoading &&
            provider.listings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.checkroom_outlined,
                    size: 20,
                    color: themeAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'All dresses shown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.totalListings} dress${provider.totalListings == 1 ? '' : 'es'} available',
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
      ],
    );
  }
}
