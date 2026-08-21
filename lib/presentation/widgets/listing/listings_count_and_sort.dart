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
            style: Theme.of(context).textTheme.bodySmall,
          ),
          // Deliberately unchrome-d: no fill, no border, no pill. This is a
          // text action, not a button — the leading sort icon carries the
          // affordance. Keep it that way.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSortSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_vert_rounded, size: 16, color: themeTaupe),
                    const SizedBox(width: 4),
                    Text(
                      currentLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
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
