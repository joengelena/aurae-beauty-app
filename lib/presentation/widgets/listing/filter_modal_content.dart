import 'package:flutter/material.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/range_filter.dart';
import 'package:shine_app/utils/filter_utils.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

/// Modal content for the filter bottom sheet
/// Displays equal filters (dropdowns) and range filters (text inputs)
class FilterModalContent extends StatelessWidget {
  const FilterModalContent({super.key});

  /// Builds a dropdown filter widget for equal filters
  Widget _buildEqualFilterRow(
    String filterKey,
    List<String> options,
    String selectedValue,
    FilteringProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              FilterUtils.filterDisplayNames[filterKey] ?? filterKey,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Dropdown
          Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: themePrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    isExpanded: true,
                    items: options.map((val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        provider.updateEqualFilter(filterKey, newVal);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteringProvider = context.watch<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();
    final listingAttributeOptions = filteringProvider.listingAttributeOptions;
    final selectedEqualFilters = filteringProvider.selectedEqualFilters;

    // Define the desired filter order (dress-relevant filters first)
    final orderedFilterKeys = [
      'location',
      'vehicle_condition',
      'make',
      'body_type',
    ];

    // Create a map for quick lookup of filter options
    final filterOptionsMap = {
      for (var attr in listingAttributeOptions) attr.name: attr.attributeValues
    };

    // Get remaining filters (not in ordered list)
    final remainingFilterKeys = listingAttributeOptions
        .map((attr) => attr.name)
        .where((key) => !orderedFilterKeys.contains(key))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ordered equal filters
                  ...orderedFilterKeys.map((filterKey) {
                    final options = filterOptionsMap[filterKey];
                    if (options == null) return const SizedBox.shrink();
                    return _buildEqualFilterRow(
                      filterKey,
                      options,
                      selectedEqualFilters[filterKey] ?? 'None',
                      filteringProvider,
                    );
                  }),

                  // Range filters section
                  RangeFilter(
                    label: 'Price',
                    fromKey: 'priceFrom',
                    toKey: 'priceTo',
                    prefixText: '\$',
                    provider: filteringProvider,
                  ),

                  // Remaining equal filters
                  ...remainingFilterKeys.map((filterKey) {
                    final options = filterOptionsMap[filterKey];
                    if (options == null) return const SizedBox.shrink();
                    return _buildEqualFilterRow(
                      filterKey,
                      options,
                      selectedEqualFilters[filterKey] ?? 'None',
                      filteringProvider,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    listingsProvider.applyFilters(
                      filteringProvider.getAllFilters(),
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
