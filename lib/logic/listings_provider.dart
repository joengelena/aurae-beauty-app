import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingsProvider extends ChangeNotifier {
  ListingsProvider();

  final Map<String, String> sortByOptions = {
    'Highest price': 'priceDesc',
    'Lowest price': 'priceAsc',
    'Latest listings': 'uploadDateDesc',
    'Oldest listings': 'uploadDateAsc',
    'Highest kilometers': 'kilometersDesc',
    'Lowest kilometers': 'kilometersAsc',
    'Latest year': 'yearDesc',
    'Oldest year': 'yearAsc',
  };
  final List<Listing> listings = [];
  final int limit = 10;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();

  String sortBy = 'uploadDateDesc';

  Map<String, String> equalFilters = {};

  Map<String, dynamic> get searchParams => {
    'searchString': searchController.text,
    'sortBy': sortBy,
    ...getEqualFilters(),
  };

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;

  Future<void> getNewListings() async {
    listings.clear();
    currentPage = 0;

    isLoading = true;
    notifyListeners();

    await fetchListings();
    return;
  }

  Future<void> getMoreListings() async {
    isLoading = true;
    notifyListeners();
    await fetchListings();
    return;
  }

  Future<void> fetchListings() async {
    try {
      final resp = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
          'searchString': searchController.text,
          'sortBy': sortBy,
          ...getEqualFilters(),
        },
      );

      listings.addAll(resp.data);
      totalPages = resp.totalPages;
      currentPage = resp.pageNumber;
      totalListings = resp.totalRows;
    } catch (e) {
      if (e is AppException) {
        debugPrint('Error loading listings: ${e.message}');
      } else {
        debugPrint('Error loading listings: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> getEqualFilters() {
    final Map<String, String> queryFilterOptions = {
      'make': 'make',
      'location': 'location',
      'vehicle_condition': 'vehicleCondition',
      'fuel_type': 'fuelType',
      'body_type': 'bodyType',
      'drive_type': 'driveType',
      'transmission': 'transmission',
      'cylinders': 'cylinders',
    };

    return Map.fromEntries(
      equalFilters.entries
          .where((entry) => entry.value != 'None')
          .map((e) => MapEntry(queryFilterOptions[e.key]!, e.value)),
    );
  }

  void updateSelectedEqualFilters(Map<String, String> newEqualFilters) {
    equalFilters = Map.from(newEqualFilters);
    getNewListings();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
