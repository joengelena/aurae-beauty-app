import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/filter_bar.dart';
import 'package:shine_app/presentation/widgets/listing/listings_count_and_sort.dart';
import 'package:provider/provider.dart';

class FiltersAndSortBar extends StatefulWidget {
  const FiltersAndSortBar({super.key});

  @override
  State<FiltersAndSortBar> createState() => _FiltersAndSortBarState();
}

class _FiltersAndSortBarState extends State<FiltersAndSortBar> {
  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            FilterBar(),
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
