import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_attributes_provider.dart';
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
    final provider = context.read<ListingAttributesProvider>();

    return FilledButton(
      onPressed: () {
        provider.updateEqualFilter(filterKey, 'None');
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final provider = context.watch<ListingAttributesProvider>();
        final listingAttributeOptions = provider.listingAttributeOptions;
        final selectedEqualFilters = provider.selectedEqualFilters;
        final updateSelectedEqualFilter = provider.updateEqualFilter;

        return Padding(
          padding: EdgeInsets.all(16),
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
                                        updateSelectedEqualFilter(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEqualFilters =
        context.watch<ListingAttributesProvider>().selectedEqualFilters;

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
            for (var entry in selectedEqualFilters.entries)
              if (entry.value != 'None')
                selectedFilter(context, entry.key, entry.value),
          ],
        ],
      ),
    );
  }
}
