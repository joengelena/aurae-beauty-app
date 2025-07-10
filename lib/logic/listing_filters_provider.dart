import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_filter.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingFiltersProvider extends ChangeNotifier {
  ListingFiltersProvider() {
    _loadFilters();
  }

  List<ListingFilter> filterOptions = [];
  Map<String, String> selectedFilters = {};

  Future<void> _loadFilters() async {
    try {
      filterOptions = await ListingsServices().getListingFilters();

      selectedFilters = {
        for (var filter in filterOptions)
          filter.name: filter.filterValues.first,
      };
    } catch (e) {
      debugPrint('Error loading filters: $e');
    } finally {
      notifyListeners();
    }
  }

  void updateFilter(String filterName, String newValue) {
    if (!selectedFilters.containsKey(filterName)) return;

    selectedFilters[filterName] = newValue;
    notifyListeners();
  }

  String? getSelected(String filterName) => selectedFilters[filterName];
}
