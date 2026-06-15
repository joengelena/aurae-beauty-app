import 'package:flutter/material.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/data/services/listings_services.dart';
import 'package:shine_app/data/services/user_services.dart';
import 'package:shine_app/utils/secure_storage.dart';

class ListingDetailProvider extends ChangeNotifier {
  ListingDetailProvider();

  Listing? listing;
  User? listingOwner;
  List<BookedRange> bookings = [];
  String? currentUserId;
  bool isLoading = false;
  bool _isSignedIn = false;

  bool get isOwnListing =>
      currentUserId != null &&
      listing != null &&
      listing!.userIdFk == currentUserId;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> getListing(int listingId) async {
    try {
      isLoading = true;
      notifyListeners();

      final listingFuture = ListingsServices().getListing(listingId);
      final bookingsFuture = DressServices().getPublicDressBookings(listingId);
      final userIdFuture = SecureStorage.read('userId');

      listing = await listingFuture;
      currentUserId = await userIdFuture;

      if (listing?.userIdFk != null && listing!.userIdFk.isNotEmpty) {
        try {
          listingOwner = await UserServices().getUserWithId(listing!.userIdFk);
        } catch (e) {
          listingOwner = null;
        }
      }

      try {
        bookings = await bookingsFuture;
      } catch (e) {
        bookings = [];
      }
    } catch (e) {
      listing = null;
      listingOwner = null;
      bookings = [];
      currentUserId = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    listing = null;
    listingOwner = null;
    bookings = [];
    currentUserId = null;
    isLoading = false;
    notifyListeners();
  }
}
