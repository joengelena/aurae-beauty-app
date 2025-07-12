import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_filters_provider.dart';
import 'package:provider/provider.dart';

class FilterBar extends StatelessWidget {
  final Map<String, String> filterNames = {
    'location': 'Location',
    'vehicle_condition': 'Condition',
    'fuel_type': 'Fuel',
    'body_type': 'Body style',
    'drive_type': 'Drive type',
    'transmission': 'Transmission',
    'cylinders': 'Cylinders',
  };

  FilterBar({super.key});

  Widget _buildChip(String label) {
    return FilterChip(label: Text(label), selected: true, onSelected: (_) {});
  }

  void showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final provider = context.watch<ListingFiltersProvider>();
        final equalFilterOptions = provider.equalFilterOptions;
        final selectedEqualFilters = provider.selectedEqualFilters;
        final updateSelectedEqualFilter = provider.updateEqualFilter;

        return Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  equalFilterOptions.map((filterOption) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Label
                          Expanded(
                            flex: 2,
                            child: Text(
                              filterNames[filterOption.name] ??
                                  filterOption.name,
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
                                        selectedEqualFilters[filterOption.name],
                                    isExpanded: true,
                                    items:
                                        filterOption.filterValues.map((val) {
                                          return DropdownMenuItem<String>(
                                            value: val,
                                            child: Text(val),
                                          );
                                        }).toList(),
                                    onChanged: (newVal) {
                                      if (newVal != null) {
                                        updateSelectedEqualFilter(
                                          filterOption.name,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            icon: Icon(
              Icons.tune,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              'Filters',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              showFiltersBottomSheet(context);
            },
          ),
          _buildChip("Used"),
          _buildChip("2WD"),
          _buildChip("Auckland"),
          _buildChip("Toyota"),
        ],
      ),
    );
  }
}
