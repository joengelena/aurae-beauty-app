import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/watchlist_services.dart';

class WatchlistProvider extends ChangeNotifier {
  final List<Listing> watchlist = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWatchlist() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await WatchlistServices().getWatchlist();

      watchlist.clear();
      watchlist.addAll(result);

      debugPrint('📚 Watchlist loaded: ${watchlist.length} items');
      for (var listing in watchlist) {
        debugPrint('  - ID: ${listing.id}, ${listing.year} ${listing.make} ${listing.model}');
      }
    } catch (e) {
      errorMessage = 'Failed to load watchlist';
      debugPrint('Error loading watchlist: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int listingId) async {
    try {
      await WatchlistServices().removeFromWatchlist(listingId);

      watchlist.removeWhere((listing) => listing.id == listingId);
      debugPrint('🗑️ Removed listing $listingId from watchlist. Remaining: ${watchlist.length} items');
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from watchlist: $e');
      rethrow;
    }
  }

  Future<void> addToWatchlist(int listingId) async {
    try {
      await WatchlistServices().addToWatchlist(listingId);
      debugPrint('➕ Added listing $listingId to watchlist');

      // Refetch watchlist to update local state
      await fetchWatchlist();
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
      rethrow;
    }
  }

  bool isInWatchlist(int listingId) {
    return watchlist.any((listing) => listing.id == listingId);
  }
}
