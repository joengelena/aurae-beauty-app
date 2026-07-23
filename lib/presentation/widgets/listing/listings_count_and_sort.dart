import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/sort_sheet.dart';
import 'package:shine_app/utils/theme.dart';

class ListingsCountAndSort extends StatelessWidget {
  final ListingsProvider listingsProvider;
  final VoidCallback onSortChanged;

  const ListingsCountAndSort({
    super.key,
    required this.listingsProvider,
    required this.onSortChanged,
  });

  Future<void> _showSortSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SortSheet(
        optionsByLabel: listingsProvider.sortByOptions,
        selectedValue: listingsProvider.sortBy,
      ),
    );
    if (picked != null && picked != listingsProvider.sortBy) {
      listingsProvider.sortBy = picked;
      onSortChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLabel = listingsProvider.sortByOptions.entries
        .firstWhere(
          (entry) => entry.value == listingsProvider.sortBy,
          orElse: () => listingsProvider.sortByOptions.entries.first,
        )
        .key;

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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSortSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: themePrimary, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_vert_rounded, size: 15, color: themeTaupe),
                    const SizedBox(width: 4),
                    Text(
                      currentLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: themeTaupe),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
