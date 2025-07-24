import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_filter.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingAttributesProvider extends ChangeNotifier {
  ListingAttributesProvider() {
    _loadFilters();
  }

  List<ListingFilter> equalFilterOptions = [];
  Map<String, String> selectedEqualFilters = {};

  Future<void> _loadFilters() async {
    try {
      equalFilterOptions = await ListingsServices().getListingFilters();

      selectedEqualFilters = {
        for (var filter in equalFilterOptions)
          filter.name: filter.filterValues.first,
      };
    } catch (e) {
      debugPrint('Error loading filters: $e');
    } finally {
      notifyListeners();
    }
  }

  void updateEqualFilter(String filterName, String newValue) {
    if (!selectedEqualFilters.containsKey(filterName)) return;

    selectedEqualFilters[filterName] = newValue;
    notifyListeners();
  }

  String? getSelected(String filterName) => selectedEqualFilters[filterName];
}
