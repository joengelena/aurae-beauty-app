import 'package:flutter/material.dart';
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
  String? _userLocation;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  void updateUserLocation(String? userLocation) {
    final bool locationChanged = _userLocation != userLocation;
    _userLocation = userLocation;

    if (!locationChanged) return;

    // Apply default location filter if user is signed in
    if (_isSignedIn && _userLocation != null) {
      // Check if location filter hasn't been explicitly set or removed by user
      final hasNoLocationFilter =
          !equalFilters.containsKey('location') ||
          equalFilters['location'] == null ||
          equalFilters['location'] == 'None';

      if (hasNoLocationFilter) {
        equalFilters['location'] = _userLocation!;
      }
    }
  }

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
      // Apply default location filter if user is signed in and has location
      final filters = _getFiltersWithDefault();

      final res = await DressServices().getPublicDresses(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
        },
      );

      final fetchedListings = res.data;

      final existingIds = listings.map((l) => l.id).toSet();
      listings.addAll(fetchedListings.where((l) => !existingIds.contains(l.id)));
      totalPages = res.totalPages;
      currentPage = res.pageNumber;
      totalListings = res.totalRows;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch listings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
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
    listings.clear();
    latestListings.clear();
    currentPage = 0;
    totalPages = 1;
    totalListings = 0;
    searchController.clear();
    sortBy = 'uploadDateDesc';
    equalFilters = {};
    _userLocation = null;
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
