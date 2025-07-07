import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class ListingsProvider extends ChangeNotifier {
  final List<Listing> listings = [];
  final int limit;
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  TextEditingController searchController = TextEditingController();
  String prevSearchControllerText = '';

  ListingsProvider({this.limit = 10});

  bool get onLastPage => _currentPage >= _totalPages;
  bool get isLoading => _isLoading;
  bool get canLoadMore =>
      !onLastPage && !_isLoading && _currentPage <= _totalPages;

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    _isLoading = true;
    notifyListeners();

    if (newSearchParameters()) {
      listings.clear();
      _currentPage = 0;
    }

    try {
      final resp = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': _currentPage + 1,
          'searchString': searchController.text,
        },
      );

      listings.addAll(resp.data);
      _totalPages = resp.totalPages;
      _currentPage = resp.pageNumber;
    } catch (e) {
      debugPrint('Error loading listings: $e');
    } finally {
      _isLoading = false;
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
