import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/utils/filter_utils.dart';

class ListingsProvider extends ChangeNotifier {
  final Map<String, String> sortByOptions = {
    'Highest price': 'priceDesc',
    'Lowest price': 'priceAsc',
    'Latest listings': 'uploadDateDesc',
    'Oldest listings': 'uploadDateAsc',
  };
  final List<Listing> listings = [];
  final List<Listing> latestListings = [];
  final int limit = 10;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;
  bool isLoadingLatest = false;

  TextEditingController searchController = TextEditingController();

  String sortBy = 'uploadDateDesc';

  Map<String, String> equalFilters = {};
  bool _isSignedIn = false;
  String _errorMessage = '';

  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;

  // Bumped on every new fetch and on reset. A response whose generation is no
  // longer current belongs to a superseded query (new search/filter/sort or a
  // sign-out) and is dropped, so it can't append to or overwrite newer results.
  int _requestGeneration = 0;

  Future<void> getNewListings() async {
    final generation = ++_requestGeneration;
    listings.clear();
    currentPage = 0;

    isLoading = true;
    notifyListeners();

    await _fetchListings(generation);
  }

  Future<void> getMoreListings() async {
    // A fetch already in flight (a new query or the previous page) owns the
    // pagination state; starting another would request the same page twice.
    if (isLoading) return;
    final generation = ++_requestGeneration;
    isLoading = true;
    notifyListeners();
    await _fetchListings(generation);
  }

  Future<void> _fetchListings(int generation) async {
    _errorMessage = '';
    try {
      final filters = _getFiltersWithDefault();
      final allQueries = <String, dynamic>{
        'limit': limit,
        'pageNumber': currentPage + 1,
        'sortBy': sortBy,
        ...filters,
      };
      final q = searchController.text.trim();
      if (q.isNotEmpty) allQueries['q'] = q;

      final res = await DressServices().getPublicDresses(allQueries: allQueries);
      if (generation != _requestGeneration) return;

      final fetchedListings = res.data;

      final existingIds = listings.map((l) => l.id).toSet();
      listings.addAll(fetchedListings.where((l) => !existingIds.contains(l.id)));
      totalPages = res.totalPages;
      currentPage = res.pageNumber;
      totalListings = res.totalRows;
    } on AppException catch (e) {
      debugPrint('⚠️ Failed to fetch listings: ${e.message}');
      if (generation == _requestGeneration) _errorMessage = e.message;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch listings: $e');
      if (generation == _requestGeneration) {
        _errorMessage = 'An unexpected error occurred while loading dresses.';
      }
    } finally {
      if (generation == _requestGeneration) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Map<String, String> _getFiltersWithDefault() {
    return FilterUtils.toApiQueryParams(equalFilters);
  }

  Map<String, String> getEqualFilters() {
    return FilterUtils.toApiQueryParams(equalFilters);
  }

  void applyFilters(Map<String, String> newEqualFilters) {
    equalFilters = Map.from(newEqualFilters);
    getNewListings();
  }

  Future<void> fetchLatestListings() async {
    isLoadingLatest = true;
    notifyListeners();

    try {
      final res = await DressServices().getPublicDresses(
        allQueries: {
          'limit': 10,
          'pageNumber': 1,
        },
      );

      final fetchedListings = res.data;

      latestListings.clear();
      latestListings.addAll(fetchedListings);
    } catch (e) {
      debugPrint('⚠️ Failed to fetch latest listings: $e');
    } finally {
      isLoadingLatest = false;
      notifyListeners();
    }
  }

  void toggleWatchlistStatus(int listingId, bool newStatus) {
    // Update in main listings
    final index = listings.indexWhere((listing) => listing.id == listingId);
    if (index != -1) {
      listings[index] = listings[index].copyWith(isInWatchlist: newStatus);
    }

    // Update in latest listings
    final latestIndex = latestListings.indexWhere(
      (listing) => listing.id == listingId,
    );
    if (latestIndex != -1) {
      latestListings[latestIndex] = latestListings[latestIndex].copyWith(
        isInWatchlist: newStatus,
      );
    }

    notifyListeners();
  }

  void reset() {
    _requestGeneration++;
    listings.clear();
    latestListings.clear();
    currentPage = 0;
    totalPages = 1;
    totalListings = 0;
    searchController.clear();
    sortBy = 'uploadDateDesc';
    equalFilters = {};
    _errorMessage = '';
    isLoading = false;
    isLoadingLatest = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
