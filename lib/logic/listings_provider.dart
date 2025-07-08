import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingsProvider extends ChangeNotifier {
  final List<Listing> listings = [];
  final int limit;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();
  String prevSearchControllerText = '';

  ListingsProvider({this.limit = 10});

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;

  Future<void> getListings() async {
    if (newSearchParameters()) {
      // get listings with pageNumber 1
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
        },
      );

      listings.addAll(resp.data);
      totalPages = resp.totalPages;
      currentPage = resp.pageNumber;
      totalListings = resp.totalRows;
    } catch (e) {
      debugPrint('Error loading listings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool newSearchParameters() {
    if (prevSearchControllerText != searchController.text) {
      return true;
    }

    return false;
  }
}
