import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/utils/theme.dart';

class ListingsCountAndSort extends StatelessWidget {
  final ListingsProvider listingsProvider;
  final VoidCallback onSortChanged;

  const ListingsCountAndSort({
    super.key,
    required this.listingsProvider,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${listingsProvider.totalListings} dress${listingsProvider.totalListings == 1 ? '' : 'es'}",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: themeTaupe,
            ),
          ),
          DropdownButton<String>(
            value: listingsProvider.sortBy,
            underline: const SizedBox(),
            isDense: true,
            style: TextStyle(fontSize: 12, color: themeText, fontFamily: 'Poppins'),
            items: listingsProvider.sortByOptions.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                listingsProvider.sortBy = value;
                onSortChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}
