import 'package:flutter/material.dart';
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/data/services/user_services.dart';

class ListingDetailProvider extends ChangeNotifier {
  ListingDetailProvider();

  Listing? listing;
  User? listingOwner;
  bool isLoading = false;
  bool _isSignedIn = false;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      // User signed out, clear cached listing data
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> getListing(int listingId) async {
    try {
      isLoading = true;
      notifyListeners();

      listing = await ListingsServices().getListing(listingId);

      if (listing?.userIdFk != null && listing!.userIdFk.isNotEmpty) {
        try {
          listingOwner = await UserServices().getUserWithId(listing!.userIdFk);
        } catch (e) {
          listingOwner = null;
        }
      }

      // Increment view count only if viewer is not the owner
      _incrementViewCountIfNotOwner(listingId);
    } catch (e) {
      listing = null;
      listingOwner = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _incrementViewCountIfNotOwner(int listingId) async {
    try {
      final currentUserId = await ApiClient().getUserId();

      // Only increment if user is not the owner (or if not logged in)
      if (listing != null && currentUserId != listing!.userIdFk) {
        debugPrint(
          'Incrementing view count for listing $listingId (viewer: ${currentUserId ?? "anonymous"}, owner: ${listing!.userIdFk})',
        );
        await ListingsServices().incrementViewCount(listingId);
      } else {
        debugPrint(
          'Skipping view count increment - user is the owner of listing $listingId',
        );
      }
    } catch (e) {
      debugPrint('Failed to increment view count: $e');
    }
  }

  void reset() {
    listing = null;
    listingOwner = null;
    isLoading = false;
    notifyListeners();
  }
}
