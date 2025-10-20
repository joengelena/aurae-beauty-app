import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_attributes_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_preview.dart';

class InfiniteGrid extends StatefulWidget {
  const InfiniteGrid({super.key});

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    // Wait until the widget has finished building first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeListings();
    });

    // Scroll listener
    _scrollController.addListener(() {
      final provider = context.read<ListingsProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          provider.canLoadMore) {
        provider.getMoreListings();
      }
    });
  }

  Future<void> _initializeListings() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final attributesProvider = context.read<ListingAttributesProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Wait for attributes to load (if not already loaded)
    while (attributesProvider.listingAttributeOptions.isEmpty) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    // Set initial filters from attributes provider
    listingsProvider.equalFilters = Map.from(attributesProvider.selectedEqualFilters);

    // Now fetch listings with the initialized filters
    await listingsProvider.getNewListings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount =
        width > 1000
            ? 4
            : width > 600
            ? 3
            : 2;
    final previewWidth = (width - (15 * crossAxisCount)) / crossAxisCount;

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children:
              provider.listings
                  .map(
                    (listing) =>
                        ListingPreview(width: previewWidth, listing: listing),
                  )
                  .toList(),
        ),

        if (provider.isLoading)
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
