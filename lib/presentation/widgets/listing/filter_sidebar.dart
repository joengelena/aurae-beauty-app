import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/presentation/widgets/listing/range_filter.dart';
import 'package:shine_app/utils/auth_prompt.dart';
import 'package:shine_app/utils/filter_utils.dart';
import 'package:shine_app/utils/theme.dart';

/// Persistent left-hand filter menu shown on wide/web Browse layouts.
/// A non-modal, live-apply counterpart to [FilterModalContent] — every
/// selection re-fetches the grid immediately instead of staging behind an
/// "Apply" button.
class FilterSidebar extends StatelessWidget {
  const FilterSidebar({super.key});

  static const double width = 260;

  static const _authReason = 'Join to filter by size, colour, and availability.';

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: themeTaupe,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  bool _hasActiveFilters(FilteringProvider p) {
    return p.selectedEqualFilters.values.any((v) => v != 'Any') ||
        p.selectedRangeFilters.values.any((v) => v.isNotEmpty) ||
        p.selectedDateRange != null;
  }

  void _clearAll(BuildContext context, FilteringProvider filteringProvider) {
    if (!requireAuth(context, reason: _authReason)) return;
    for (final key in filteringProvider.selectedEqualFilters.keys.toList()) {
      filteringProvider.updateEqualFilter(key, 'Any');
    }
    filteringProvider.clearRangeFilters();
    filteringProvider.clearDateRange();
    context.read<ListingsProvider>().applyFilters(filteringProvider.getAllFilters());
  }

  // Same dropdown control as FilterModalContent (label + outlined select),
  // stacked instead of side-by-side since the sidebar column is much
  // narrower than the bottom sheet — matches RangeFilter's label-above-field
  // layout already used lower in this panel.
  Widget _buildFilterGroup(
    BuildContext context,
    String filterKey,
    List<String> options,
    String selectedValue,
    FilteringProvider filteringProvider,
  ) {
    final validValue = options.contains(selectedValue) ? selectedValue : 'Any';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FilterUtils.filterDisplayNames[filterKey] ?? filterKey,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (newVal) {
                  if (newVal == null) return;
                  if (!requireAuth(context, reason: _authReason)) return;
                  filteringProvider.updateEqualFilter(filterKey, newVal);
                  context
                      .read<ListingsProvider>()
                      .applyFilters(filteringProvider.getAllFilters());
                },
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

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: themePrimary.withValues(alpha: 0.6)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeText,
                  ),
                ),
                if (_hasActiveFilters(filteringProvider))
                  TextButton(
                    onPressed: () => _clearAll(context, filteringProvider),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Clear all', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),

            _sectionLabel('Availability'),
            CalendarDateRangePicker(
              initialStart: filteringProvider.selectedDateRange?.start,
              initialEnd: filteringProvider.selectedDateRange?.end,
              placeholder: 'Any dates',
              onChanged: (start, end) {
                if (!requireAuth(context, reason: _authReason)) return;
                if (start != null && end != null) {
                  filteringProvider.updateDateRange(
                      DateTimeRange(start: start, end: end));
                } else {
                  filteringProvider.clearDateRange();
                }
                context
                    .read<ListingsProvider>()
                    .applyFilters(filteringProvider.getAllFilters());
              },
            ),

            _sectionLabel('Dress details'),
            ...orderedFilterKeys.map((filterKey) {
              final options = filterOptionsMap[filterKey];
              if (options == null) return const SizedBox.shrink();
              return _buildFilterGroup(
                context,
                filterKey,
                options,
                selectedEqualFilters[filterKey] ?? 'Any',
                filteringProvider,
              );
            }),
            ...remainingFilterKeys.map((filterKey) {
              final options = filterOptionsMap[filterKey];
              if (options == null) return const SizedBox.shrink();
              return _buildFilterGroup(
                context,
                filterKey,
                options,
                selectedEqualFilters[filterKey] ?? 'Any',
                filteringProvider,
              );
            }),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
              onSubmitted: () {
                if (!requireAuth(context, reason: _authReason)) return;
                context
                    .read<ListingsProvider>()
                    .applyFilters(filteringProvider.getAllFilters());
              },
            ),
          ],
        ),
      ),
    );
  }
}
