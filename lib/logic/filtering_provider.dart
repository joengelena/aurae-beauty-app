import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class FilteringProvider extends ChangeNotifier {
  FilteringProvider() {
    _loadAttributes();
  }

  List<ListingAttribute> listingAttributeOptions = [];
  Map<String, String> selectedEqualFilters = {};

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
      // Silently handle filter loading errors
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
}
