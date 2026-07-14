import 'package:flutter/material.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/presentation/widgets/listing/range_filter.dart';
import 'package:shine_app/utils/filter_utils.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class FilterModalContent extends StatefulWidget {
  const FilterModalContent({super.key});

  @override
  State<FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: themeTaupe,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEqualFilterRow(
    String filterKey,
    List<String> options,
    String selectedValue,
    FilteringProvider provider,
  ) {
    final validValue = options.contains(selectedValue) ? selectedValue : 'Any';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              FilterUtils.filterDisplayNames[filterKey] ?? filterKey,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: themePrimary, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: validValue,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeText,
                    fontFamily: 'Poppins',
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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

    final orderedFilterKeys = ['location', 'brand', 'dress_type', 'style'];

    final filterOptionsMap = {
      for (var attr in listingAttributeOptions) attr.name: attr.attributeValues
    };

    final remainingFilterKeys = listingAttributeOptions
        .map((attr) => attr.name)
        .where((key) => !orderedFilterKeys.contains(key))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themePrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeText,
              ),
            ),
          ),
        ),
        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Availability'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CalendarDateRangePicker(
                    initialStart: filteringProvider.selectedDateRange?.start,
                    initialEnd: filteringProvider.selectedDateRange?.end,
                    placeholder: 'Any dates',
                    onChanged: (start, end) {
                      if (start != null && end != null) {
                        filteringProvider.updateDateRange(
                            DateTimeRange(start: start, end: end));
                      } else {
                        filteringProvider.clearDateRange();
                      }
                    },
                  ),
                ),

                _sectionLabel('Dress details'),
                ...orderedFilterKeys.map((filterKey) {
                  final options = filterOptionsMap[filterKey];
                  if (options == null) return const SizedBox.shrink();
                  return _buildEqualFilterRow(
                    filterKey,
                    options,
                    selectedEqualFilters[filterKey] ?? 'Any',
                    filteringProvider,
                  );
                }),
                ...remainingFilterKeys.map((filterKey) {
                  final options = filterOptionsMap[filterKey];
                  if (options == null) return const SizedBox.shrink();
                  return _buildEqualFilterRow(
                    filterKey,
                    options,
                    selectedEqualFilters[filterKey] ?? 'Any',
                    filteringProvider,
                  );
                }),

                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 14),
                  child: Divider(
                    color: themePrimary.withValues(alpha: 0.6),
                    height: 1,
                  ),
                ),

                _sectionLabel('Price'),
                RangeFilter(
                  label: 'Price per day',
                  fromKey: 'priceFrom',
                  toKey: 'priceTo',
                  prefixText: '\$',
                  provider: filteringProvider,
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        // Action buttons
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
