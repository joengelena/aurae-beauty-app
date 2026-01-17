import 'package:flutter/material.dart';
import 'package:motorix_app/logic/filtering_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/range_filter.dart';
import 'package:motorix_app/utils/filter_utils.dart';
import 'package:provider/provider.dart';

/// Modal content for the filter bottom sheet
/// Displays equal filters (dropdowns) and range filters (text inputs)
class FilterModalContent extends StatelessWidget {
  const FilterModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    final filteringProvider = context.watch<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();
    final listingAttributeOptions = filteringProvider.listingAttributeOptions;
    final selectedEqualFilters = filteringProvider.selectedEqualFilters;

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
                  // Equal filters section
                  ...listingAttributeOptions.map((attributeOption) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Label
                          Expanded(
                            flex: 2,
                            child: Text(
                              FilterUtils.filterDisplayNames[attributeOption.name] ??
                                  attributeOption.name,
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
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedEqualFilters[attributeOption.name],
                                    isExpanded: true,
                                    items: attributeOption.attributeValues.map(
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

                  // Range filters section
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
