import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/filter_bar.dart';
import 'package:shine_app/presentation/widgets/listing/listing_search_field.dart';
import 'package:shine_app/presentation/widgets/listing/listings_count_and_sort.dart';
import 'package:provider/provider.dart';

class FiltersAndSortBar extends StatefulWidget {
  /// Whether to render the badge row + "Filters" button. Set to false when
  /// a [FilterSidebar] is already showing filter state alongside this bar.
  final bool showFilterBar;

  /// Max width of the search/sort column. Defaults to a centered 600px
  /// column for mobile; pass `double.infinity` when placed next to a sidebar
  /// so it fills the remaining width.
  final double maxWidth;

  const FiltersAndSortBar({
    super.key,
    this.showFilterBar = true,
    this.maxWidth = 600,
  });

  @override
  State<FiltersAndSortBar> createState() => _FiltersAndSortBarState();
}

class _FiltersAndSortBarState extends State<FiltersAndSortBar> {
  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListingSearchField(listingsProvider: listingsProvider),
            ),
            if (widget.showFilterBar) FilterBar(),
            ListingsCountAndSort(
              listingsProvider: listingsProvider,
              onSortChanged: () {
                setState(() {});
                listingsProvider.getNewListings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
