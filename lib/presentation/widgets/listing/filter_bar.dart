import 'package:flutter/material.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/filter_badge.dart';
import 'package:shine_app/presentation/widgets/listing/filter_modal_content.dart';
import 'package:shine_app/utils/filter_utils.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

/// Displays a horizontal scrollable bar with filter badges
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  void _showFiltersBottomSheet(BuildContext context) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    _syncFiltersWithAppliedState(filteringProvider, listingsProvider);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        return SizedBox(
          height: MediaQuery.of(modalContext).size.height * 0.88,
          child: const FilterModalContent(),
        );
      },
    );
  }

  void _syncFiltersWithAppliedState(
    FilteringProvider filteringProvider,
    ListingsProvider listingsProvider,
  ) {
    for (var key in filteringProvider.selectedEqualFilters.keys) {
      filteringProvider.selectedEqualFilters[key] =
          listingsProvider.equalFilters[key] ?? 'Any';
    }

    for (var key in filteringProvider.selectedRangeFilters.keys) {
      filteringProvider.selectedRangeFilters[key] =
          listingsProvider.equalFilters[key] ?? '';
    }

    listingsProvider.equalFilters.forEach((key, value) {
      if (!filteringProvider.selectedEqualFilters.containsKey(key) &&
          !filteringProvider.selectedRangeFilters.containsKey(key) &&
          key != 'startDate' &&
          key != 'endDate') {
        filteringProvider.selectedEqualFilters[key] = value;
      }
    });

    // Sync date range from applied filters back into provider
    final startStr = listingsProvider.equalFilters['startDate'];
    final endStr = listingsProvider.equalFilters['endDate'];
    if (startStr != null && endStr != null) {
      filteringProvider.updateDateRange(DateTimeRange(
        start: DateTime.parse(startStr),
        end: DateTime.parse(endStr),
      ));
    } else {
      filteringProvider.clearDateRange();
    }
  }

  Widget _buildDateRangeBadge(
    BuildContext context,
    String startDateStr,
    String endDateStr,
  ) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    final start = DateTime.parse(startDateStr);
    final end = DateTime.parse(endDateStr);
    final label =
        '${start.day} ${_shortMonths[start.month - 1]} – ${end.day} ${_shortMonths[end.month - 1]}';

    return FilterBadge(
      displayText: label,
      onRemove: () {
        filteringProvider.clearDateRange();
        final updated = Map<String, String>.from(listingsProvider.equalFilters)
          ..remove('startDate')
          ..remove('endDate');
        listingsProvider.applyFilters(updated);
      },
    );
  }

  Widget _buildEqualFilterBadge(
    BuildContext context,
    String filterKey,
    String filterValue,
  ) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    return FilterBadge(
      displayText: filterValue,
      onRemove: () {
        filteringProvider.updateEqualFilter(filterKey, 'Any');
        listingsProvider.applyFilters(filteringProvider.selectedEqualFilters);
      },
    );
  }

  Widget _buildRangeFilterBadge(
    BuildContext context,
    String baseKey,
    Map<String, String> rangeValues,
  ) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    final fromKey = '${baseKey}From';
    final toKey = '${baseKey}To';
    final minValue = rangeValues[fromKey] ?? '';
    final maxValue = rangeValues[toKey] ?? '';

    final displayText = FilterUtils.formatRangeFilterDisplay(
      baseKey,
      minValue,
      maxValue,
    );

    return FilterBadge(
      displayText: displayText,
      onRemove: () {
        filteringProvider.updateRangeFilter(fromKey, '');
        filteringProvider.updateRangeFilter(toKey, '');
        listingsProvider.applyFilters(filteringProvider.getAllFilters());
      },
    );
  }

  ({
    List<MapEntry<String, String>> equalFilters,
    Map<String, Map<String, String>> rangeFilters,
  })
  _categorizeAppliedFilters(Map<String, String> appliedFilters) {
    final equalFilterEntries = <MapEntry<String, String>>[];
    final rangeFilters = <String, Map<String, String>>{};

    for (var entry in appliedFilters.entries) {
      if (entry.value == 'Any' || entry.value.isEmpty) continue;
      // Date range handled separately as a combined badge
      if (entry.key == 'startDate' || entry.key == 'endDate') continue;

      if (entry.key.endsWith('From') || entry.key.endsWith('To')) {
        final baseKey = entry.key.replaceAll(RegExp(r'(From|To)$'), '');
        rangeFilters.putIfAbsent(baseKey, () => {});
        rangeFilters[baseKey]![entry.key] = entry.value;
      } else {
        equalFilterEntries.add(entry);
      }
    }

    return (equalFilters: equalFilterEntries, rangeFilters: rangeFilters);
  }

  @override
  Widget build(BuildContext context) {
    final appliedFilters = context.watch<ListingsProvider>().equalFilters;
    final categorizedFilters = _categorizeAppliedFilters(appliedFilters);

    final startDate = appliedFilters['startDate'];
    final endDate = appliedFilters['endDate'];
    final hasDateFilter = startDate != null && endDate != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          // Filters button
          OutlinedButton.icon(
            onPressed: () => _showFiltersBottomSheet(context),
            icon: Icon(Icons.tune, color: themeText, size: 18),
            label: Text(
              'Filters',
              style: TextStyle(color: themeText, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themePrimary, width: 1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              backgroundColor: Colors.white,
            ),
          ),
          // Date range badge (always first when active)
          if (hasDateFilter)
            _buildDateRangeBadge(context, startDate, endDate),
          // Equal filter badges
          ...categorizedFilters.equalFilters.map(
            (entry) => _buildEqualFilterBadge(context, entry.key, entry.value),
          ),
          // Range filter badges
          ...categorizedFilters.rangeFilters.entries.map(
            (entry) => _buildRangeFilterBadge(context, entry.key, entry.value),
          ),
        ],
      ),
    );
  }
}
