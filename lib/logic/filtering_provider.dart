import 'package:flutter/material.dart' show ChangeNotifier, DateTimeRange, debugPrint;
import 'package:shine_app/data/models/listing_attribute.dart';
import 'package:shine_app/data/services/dress_services.dart';

class FilteringProvider extends ChangeNotifier {
  FilteringProvider() {
    _loadAttributes();
  }

  List<ListingAttribute> listingAttributeOptions = [];
  Map<String, String> selectedEqualFilters = {};
  Map<String, String> selectedRangeFilters = {
    'priceFrom': '',
    'priceTo': '',
  };
  DateTimeRange? selectedDateRange;

  Future<void> _loadAttributes() async {
    try {
      final listingAttributeOptionsWithoutNone =
          await DressServices().getDressAttributes();

      // Add 'Any' option to each attribute for clearing filters
      for (var attributeWithoutNone in listingAttributeOptionsWithoutNone) {
        attributeWithoutNone.attributeValues.insert(0, 'Any');
      }
      listingAttributeOptions = listingAttributeOptionsWithoutNone;

      // Initialize all filters to 'Any' (no filter applied)
      selectedEqualFilters = {
        for (var attribute in listingAttributeOptions)
          attribute.name: attribute.attributeValues.first,
      };
    } catch (e) {
      debugPrint('⚠️ Failed to load filter options: $e');
    } finally {
      notifyListeners();
    }
  }

  void updateEqualFilter(String listingAttribute, String newValue) {
    if (!selectedEqualFilters.containsKey(listingAttribute)) return;

    selectedEqualFilters[listingAttribute] = newValue;
    notifyListeners();
  }

  String? getSelected(String filterName) => selectedEqualFilters[filterName];

  void updateRangeFilter(String filterKey, String value) {
    selectedRangeFilters[filterKey] = value;
    notifyListeners();
  }

  String getRangeValue(String filterKey) {
    return selectedRangeFilters[filterKey] ?? '';
  }

  void clearRangeFilters() {
    selectedRangeFilters = {
      'priceFrom': '',
      'priceTo': '',
    };
    notifyListeners();
  }

  void updateDateRange(DateTimeRange? range) {
    selectedDateRange = range;
    notifyListeners();
  }

  void clearDateRange() {
    selectedDateRange = null;
    notifyListeners();
  }

  Map<String, String> getAllFilters() {
    final allFilters = Map<String, String>.from(selectedEqualFilters);

    // Add non-empty range filters
    selectedRangeFilters.forEach((key, value) {
      if (value.isNotEmpty) {
        allFilters[key] = value;
      }
    });

    // Add date range as ISO date strings
    if (selectedDateRange != null) {
      allFilters['startDate'] = _isoDate(selectedDateRange!.start);
      allFilters['endDate'] = _isoDate(selectedDateRange!.end);
    }

    return allFilters;
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
