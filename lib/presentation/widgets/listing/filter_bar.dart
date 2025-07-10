import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_filter.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  Widget _buildChip(String label) {
    return FilterChip(label: Text(label), selected: true, onSelected: (_) {});
  }

  void showFiltersBottomSheet(
    BuildContext context,
    List<ListingFilter> filters,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                filters
                    .map(
                      (filter) => Row(
                        children: [
                          Text(filter.name),
                          DropdownButton<String>(
                            items:
                                filter.filterValues.map((val) {
                                  return DropdownMenuItem(
                                    value: val,
                                    child: Text(val),
                                  );
                                }).toList(),
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final filters = provider.filters;

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
              showFiltersBottomSheet(context, filters);
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
