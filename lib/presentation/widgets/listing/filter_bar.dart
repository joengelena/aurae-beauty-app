import 'package:flutter/material.dart';
import 'package:motorix_app/logic/filtering_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/range_filter.dart';
import 'package:motorix_app/utils/filter_utils.dart';
import 'package:provider/provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  Widget selectedFilter(
    BuildContext context,
    String filterKey,
    String filterValue,
  ) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    return FilledButton(
      onPressed: () {
        // Update pending filter to 'None'
        filteringProvider.updateEqualFilter(filterKey, 'None');
        // Immediately apply the change (removing a filter should be instant)
        listingsProvider.applyFilters(filteringProvider.selectedEqualFilters);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.secondary,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(filterValue),
          const SizedBox(width: 8),
          const Icon(Icons.close, size: 16),
        ],
      ),
    );
  }

  void showFiltersBottomSheet(BuildContext context) {
    // Sync pending filters with applied filters when opening the sheet
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Copy applied equal filters to pending filters
    for (var key in filteringProvider.selectedEqualFilters.keys) {
      if (listingsProvider.equalFilters.containsKey(key)) {
        filteringProvider.selectedEqualFilters[key] =
            listingsProvider.equalFilters[key]!;
      } else {
        // If filter not in applied filters, reset to 'None'
        filteringProvider.selectedEqualFilters[key] = 'None';
      }
    }

    // Copy applied range filters to pending filters
    for (var key in filteringProvider.selectedRangeFilters.keys) {
      if (listingsProvider.equalFilters.containsKey(key)) {
        filteringProvider.selectedRangeFilters[key] =
            listingsProvider.equalFilters[key]!;
      } else {
        // If filter not in applied filters, reset to empty
        filteringProvider.selectedRangeFilters[key] = '';
      }
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        final filteringProvider = modalContext.watch<FilteringProvider>();
        final listingsProvider = modalContext.read<ListingsProvider>();
        final listingAttributeOptions =
            filteringProvider.listingAttributeOptions;
        final selectedEqualFilters = filteringProvider.selectedEqualFilters;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Equal filters section
                      ...listingAttributeOptions.map((attributeOption) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Label
                              Expanded(
                                flex: 2,
                                child: Text(
                                  FilterUtils.filterDisplayNames[attributeOption
                                          .name] ??
                                      attributeOption.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            selectedEqualFilters[attributeOption
                                                .name],
                                        isExpanded: true,
                                        items:
                                            attributeOption.attributeValues.map(
                                              (val) {
                                                return DropdownMenuItem<String>(
                                                  value: val,
                                                  child: Text(val),
                                                );
                                              },
                                            ).toList(),
                                        onChanged: (newVal) {
                                          if (newVal != null) {
                                            filteringProvider.updateEqualFilter(
                                              attributeOption.name,
                                              newVal,
                                            );
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
                      }).toList(),

                      RangeFilter(
                        label: 'Price',
                        fromKey: 'priceFrom',
                        toKey: 'priceTo',
                        prefixText: '\$',
                        provider: filteringProvider,
                      ),

                      RangeFilter(
                        label: 'Year',
                        fromKey: 'yearFrom',
                        toKey: 'yearTo',
                        provider: filteringProvider,
                      ),

                      RangeFilter(
                        label: 'Kilometers',
                        fromKey: 'kilometersFrom',
                        toKey: 'kilometersTo',
                        provider: filteringProvider,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        listingsProvider.applyFilters(
                          filteringProvider.getAllFilters(),
                        );
                        Navigator.pop(modalContext);
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget selectedRangeFilter(
    BuildContext context,
    String baseKey,
    Map<String, String> values,
  ) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Get min and max values
    final fromKey = '${baseKey}From';
    final toKey = '${baseKey}To';
    final minValue = values[fromKey] ?? '';
    final maxValue = values[toKey] ?? '';

    // Format the display text
    String displayText = _formatRangeFilterDisplay(baseKey, minValue, maxValue);

    return FilledButton(
      onPressed: () {
        // Clear both min and max for this range filter
        filteringProvider.updateRangeFilter(fromKey, '');
        filteringProvider.updateRangeFilter(toKey, '');
        // Apply the change
        listingsProvider.applyFilters(filteringProvider.getAllFilters());
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.secondary,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(displayText),
          const SizedBox(width: 8),
          const Icon(Icons.close, size: 16),
        ],
      ),
    );
  }

  String _formatRangeFilterDisplay(
    String baseKey,
    String minValue,
    String maxValue,
  ) {
    // Get the display label and prefix
    String label = '';
    String prefix = '';

    switch (baseKey) {
      case 'price':
        label = 'Price';
        prefix = '\$';
        break;
      case 'year':
        label = 'Year';
        break;
      case 'kilometers':
        label = 'Kms';
        break;
    }

    // Format min and max with thousand separators for kilometers
    String formattedMin = minValue.isEmpty
        ? 'Any'
        : '$prefix${baseKey == 'kilometers' ? _formatNumber(minValue) : minValue}';
    String formattedMax = maxValue.isEmpty
        ? 'Any'
        : '$prefix${baseKey == 'kilometers' ? _formatNumber(maxValue) : maxValue}';

    return '$label: $formattedMin - $formattedMax';
  }

  String _formatNumber(String value) {
    // Add thousand separators
    final intValue = int.tryParse(value);
    if (intValue == null) return value;

    return intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Show badges based on APPLIED filters, not pending selections
    final appliedFilters = context.watch<ListingsProvider>().equalFilters;

    // Separate equal and range filters
    final equalFilterEntries = <MapEntry<String, String>>[];
    final rangeFilters = <String, Map<String, String>>{};

    for (var entry in appliedFilters.entries) {
      if (entry.value == 'None' || entry.value.isEmpty) continue;

      // Check if it's a range filter
      if (entry.key.endsWith('From') || entry.key.endsWith('To')) {
        final baseKey = entry.key.replaceAll(RegExp(r'(From|To)$'), '');
        rangeFilters.putIfAbsent(baseKey, () => {});
        rangeFilters[baseKey]![entry.key] = entry.value;
      } else {
        equalFilterEntries.add(entry);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () => showFiltersBottomSheet(context),
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            label: Text(
              'Filters',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          ),
          // Equal filter badges
          ...equalFilterEntries
              .map((entry) => selectedFilter(context, entry.key, entry.value)),
          // Range filter badges
          ...rangeFilters.entries
              .map((entry) => selectedRangeFilter(context, entry.key, entry.value)),
        ],
      ),
    );
  }
}
