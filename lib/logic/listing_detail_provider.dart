import 'package:flutter/material.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/dress_damage_incident.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/data/services/user_services.dart';
import 'package:shine_app/utils/secure_storage.dart';

class ListingDetailProvider extends ChangeNotifier {
  ListingDetailProvider();

  Listing? listing;
  User? listingOwner;
  List<BookedRange> bookings = [];
  List<DressDamageIncident> damageIncidents = [];
  // Other active listings from the same owner/brand/style — the size
  // choices a renter can pick between for "this dress". Always includes
  // the currently loaded listing, even if it's the only one.
  List<Listing> sizeVariants = [];
  String? currentUserId;
  bool isLoading = false;
  bool isSwitchingSize = false;
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

  Future<void> getListing(int listingId, {bool silent = false}) async {
    try {
      if (!silent) {
        isLoading = true;
        notifyListeners();
      }

      final listingFuture = DressServices().getPublicDressById(listingId);
      final bookingsFuture = DressServices().getPublicDressBookings(listingId);
      final damageIncidentsFuture = DressServices().getPublicDamageIncidents(listingId);
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

      try {
        damageIncidents = await damageIncidentsFuture;
      } catch (e) {
        damageIncidents = [];
      }

      await _loadSizeVariants();
    } catch (e) {
      listing = null;
      listingOwner = null;
      bookings = [];
      damageIncidents = [];
      sizeVariants = [];
      currentUserId = null;
    } finally {
      if (!silent) isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSizeVariants() async {
    final current = listing;
    if (current == null) {
      sizeVariants = [];
      return;
    }
    try {
      final result = await DressServices().getPublicDresses(
        allQueries: {
          'userId': current.userIdFk,
          'brand': current.brand,
          'style': current.style,
          'limit': '20',
        },
      );
      final variants = result.data.toList();
      if (!variants.any((l) => l.id == current.id)) variants.add(current);
      variants.sort((a, b) => a.size.compareTo(b.size));
      sizeVariants = variants;
    } catch (e) {
      sizeVariants = [current];
    }
  }

  // Switches the active listing to the size variant matching [size], without
  // triggering the full-page loading skeleton.
  Future<void> selectSize(String size) async {
    final match = sizeVariants.where((l) => l.size == size);
    if (match.isEmpty) return;
    final target = match.first;
    if (target.id == listing?.id) return;

    isSwitchingSize = true;
    notifyListeners();
    try {
      await getListing(target.id, silent: true);
    } finally {
      isSwitchingSize = false;
      notifyListeners();
    }
  }

  void reset() {
    listing = null;
    listingOwner = null;
    bookings = [];
    damageIncidents = [];
    sizeVariants = [];
    currentUserId = null;
    isLoading = false;
    isSwitchingSize = false;
    notifyListeners();
  }
}
