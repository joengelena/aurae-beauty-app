import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_filter.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingsProvider extends ChangeNotifier {
  ListingsProvider() {
    _loadFilters();
  }

  List<ListingFilter> filters = [];
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
  String prevSearchControllerText = '';

  String sortBy = 'uploadDateDesc';
  String prevSortBy = '';

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;

  Future<void> getListings() async {
    if (newSearchParameters()) {
      listings.clear();
      currentPage = 0;

      isLoading = true;
      notifyListeners();

      await fetchListings();
    }

    if (canLoadMore) {
      isLoading = true;
      notifyListeners();
      await fetchListings();
    }
  }

  Future<void> fetchListings() async {
    try {
      final resp = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
          'searchString': searchController.text,
          'sortBy': sortBy,
        },
      );

      listings.addAll(resp.data);
      totalPages = resp.totalPages;
      currentPage = resp.pageNumber;
      totalListings = resp.totalRows;

      prevSearchControllerText = searchController.text;
      prevSortBy = sortBy;
    } catch (e) {
      debugPrint('Error loading listings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool newSearchParameters() {
    if (prevSearchControllerText != searchController.text ||
        prevSortBy != sortBy) {
      return true;
    }

    return false;
  }

  Future<void> _loadFilters() async {
    try {
      filters = await ListingsServices().getListingFilters();
    } catch (e) {
      debugPrint('Error loading filters: $e');
    } finally {
      notifyListeners();
    }
  }
}
