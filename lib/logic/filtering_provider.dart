import 'package:flutter/material.dart';
import 'package:shine_app/data/models/listing_attribute.dart';
import 'package:shine_app/data/services/listings_services.dart';

class FilteringProvider extends ChangeNotifier {
  FilteringProvider() {
    _loadAttributes();
  }

  List<ListingAttribute> listingAttributeOptions = [];
  Map<String, String> selectedEqualFilters = {};
  Map<String, String> selectedRangeFilters = {
    'priceFrom': '',
    'priceTo': '',
    'yearFrom': '',
    'yearTo': '',
    'kilometersFrom': '',
    'kilometersTo': '',
  };

  Future<void> _loadAttributes() async {
    try {
      final listingAttributeOptionsWithoutNone =
          await ListingsServices().getListingAttributes();

      // Add 'None' option to each attribute for clearing filters
      for (var attributeWithoutNone in listingAttributeOptionsWithoutNone) {
        attributeWithoutNone.attributeValues.insert(0, 'None');
      }
      listingAttributeOptions = listingAttributeOptionsWithoutNone;

      // Initialize all filters to 'None' (no filter applied)
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
      'yearFrom': '',
      'yearTo': '',
      'kilometersFrom': '',
      'kilometersTo': '',
    };
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

    return allFilters;
  }
}
