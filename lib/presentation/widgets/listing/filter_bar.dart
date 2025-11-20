import 'package:flutter/material.dart';
import 'package:motorix_app/logic/filtering_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';

class FilterBar extends StatelessWidget {
  final Map<String, String> filterNames = {
    'make': 'Make',
    'location': 'Location',
    'vehicle_condition': 'Condition',
    'fuel_type': 'Fuel',
    'body_type': 'Body style',
    'drive_type': 'Drive type',
    'transmission': 'Transmission',
    'cylinders': 'Cylinders',
  };

  FilterBar({super.key});

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
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(filterValue),
          SizedBox(width: 8),
          Icon(Icons.close, size: 16),
        ],
      ),
    );
  }

  void showFiltersBottomSheet(BuildContext context) {
    // Sync pending filters with applied filters when opening the sheet
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Copy applied filters to pending filters
    for (var key in filteringProvider.selectedEqualFilters.keys) {
      if (listingsProvider.equalFilters.containsKey(key)) {
        filteringProvider.selectedEqualFilters[key] =
            listingsProvider.equalFilters[key]!;
      } else {
        // If filter not in applied filters, reset to 'None'
        filteringProvider.selectedEqualFilters[key] = 'None';
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        final filteringProvider = modalContext.watch<FilteringProvider>();
        final listingsProvider = modalContext.read<ListingsProvider>();
        final listingAttributeOptions = filteringProvider.listingAttributeOptions;
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
                    children:
                        listingAttributeOptions.map((attributeOption) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Label
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    filterNames[attributeOption.name] ??
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
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value:
                                              selectedEqualFilters[attributeOption
                                                  .name],
                                          isExpanded: true,
                                          items:
                                              attributeOption.attributeValues.map((
                                                val,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: val,
                                                  child: Text(val),
                                                );
                                              }).toList(),
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
                          filteringProvider.selectedEqualFilters,
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

  @override
  Widget build(BuildContext context) {
    // Show badges based on APPLIED filters, not pending selections
    final appliedFilters =
        context.watch<ListingsProvider>().equalFilters;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () => showFiltersBottomSheet(context),
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
            label: Text(
              'Filters',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          ...[
            for (var entry in appliedFilters.entries)
              if (entry.value != 'None')
                selectedFilter(context, entry.key, entry.value),
          ],
        ],
      ),
    );
  }
}
