import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_preview.dart';
import 'package:motorix_app/presentation/widgets/listing/search_and_filter_bar.dart';

class InfiniteGrid extends StatefulWidget {
  const InfiniteGrid({super.key});

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Wait until the widget has finished building first before "loadMore()"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadMore();
    });

    // Scroll listener
    _scrollController.addListener(() {
      final provider = context.read<ListingsProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          provider.canLoadMore) {
        provider.loadMore();
      }
    });
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
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: Wrap(
            spacing: 6,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children:
                provider.listings
                    .map(
                      (listing) =>
                          ListingPreview(width: previewWidth, listing: listing),
                    )
                    .toList(),
          ),
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
