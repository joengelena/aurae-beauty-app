import 'package:flutter/material.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/services/watchlist_services.dart';

class WatchlistProvider extends ChangeNotifier {
  final List<Listing> watchlist = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isSignedIn = false;

  void updateAuthStatus(bool isSignedIn) {
    if (isSignedIn && !_isSignedIn) {
      fetchWatchlist();
    } else if (!isSignedIn && _isSignedIn) {
      clearWatchlist();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> fetchWatchlist() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await WatchlistServices().getWatchlist();

      watchlist.clear();
      watchlist.addAll(result);
    } catch (e) {
      errorMessage = 'Failed to load watchlist';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int listingId) async {
    try {
      await WatchlistServices().removeFromWatchlist(listingId);

      watchlist.removeWhere((listing) => listing.id == listingId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToWatchlist(int listingId) async {
    try {
      await WatchlistServices().addToWatchlist(listingId);

      // Refetch watchlist to update local state
      await fetchWatchlist();
    } catch (e) {
      rethrow;
    }
  }

  bool isInWatchlist(int listingId) {
    return watchlist.any((listing) => listing.id == listingId);
  }

  void clearWatchlist() {
    watchlist.clear();
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
