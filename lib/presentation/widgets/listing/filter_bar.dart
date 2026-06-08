import 'package:flutter/material.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/filter_badge.dart';
import 'package:shine_app/presentation/widgets/listing/filter_modal_content.dart';
import 'package:shine_app/utils/filter_utils.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

/// Displays a horizontal scrollable bar with filter badges
/// Shows active filters and allows users to remove or add filters
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  void _showFiltersBottomSheet(BuildContext context) {
    final filteringProvider = context.read<FilteringProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Sync pending filters with applied filters when opening the sheet
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
          height: MediaQuery.of(modalContext).size.height * 0.6,
          child: const FilterModalContent(),
        );
      },
    );
  }

  /// Syncs pending filter state with currently applied filters
  void _syncFiltersWithAppliedState(
    FilteringProvider filteringProvider,
    ListingsProvider listingsProvider,
  ) {
    for (var key in filteringProvider.selectedEqualFilters.keys) {
      filteringProvider.selectedEqualFilters[key] =
          listingsProvider.equalFilters[key] ?? 'None';
    }

    for (var key in filteringProvider.selectedRangeFilters.keys) {
      filteringProvider.selectedRangeFilters[key] =
          listingsProvider.equalFilters[key] ?? '';
    }

    listingsProvider.equalFilters.forEach((key, value) {
      if (!filteringProvider.selectedEqualFilters.containsKey(key) &&
          !filteringProvider.selectedRangeFilters.containsKey(key)) {
        filteringProvider.selectedEqualFilters[key] = value;
      }
    });
  }

  /// Creates a badge for an equal filter (e.g., "Toyota", "Dubai")
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
        filteringProvider.updateEqualFilter(filterKey, 'None');
        listingsProvider.applyFilters(filteringProvider.selectedEqualFilters);
      },
    );
  }

  /// Creates a badge for a range filter (e.g., "Price: $1000 - $5000")
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

  /// Separates applied filters into equal and range filter categories
  ({
    List<MapEntry<String, String>> equalFilters,
    Map<String, Map<String, String>> rangeFilters,
  })
  _categorizeAppliedFilters(Map<String, String> appliedFilters) {
    final equalFilterEntries = <MapEntry<String, String>>[];
    final rangeFilters = <String, Map<String, String>>{};

    for (var entry in appliedFilters.entries) {
      if (entry.value == 'None' || entry.value.isEmpty) continue;

      // Check if it's a range filter (ends with From or To)
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
              side: BorderSide(color: const Color(0xFFDDD4CF), width: 1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              backgroundColor: Colors.white,
            ),
          ),
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
