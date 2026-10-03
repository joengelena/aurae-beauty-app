import 'package:flutter/material.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/dress_damage_incident.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/data/services/user_services.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:shine_app/utils/size_utils.dart';

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

  // Bumped on every load and on reset. Loads can overlap (tapping sizes
  // quickly, or navigating between dresses), and only the latest one may
  // write state — otherwise a slow earlier response lands last and the page
  // shows dress A's photos with dress B's bookings.
  int _requestGeneration = 0;

  Future<void> getListing(int listingId, {bool silent = false}) async {
    final generation = ++_requestGeneration;
    try {
      if (!silent) {
        isLoading = true;
        notifyListeners();
      }

      final listingFuture = DressServices().getPublicDressById(listingId);
      final bookingsFuture = DressServices().getPublicDressBookings(listingId);
      final damageIncidentsFuture = DressServices().getPublicDamageIncidents(listingId);
      final userIdFuture = SecureStorage.read('userId');

      final loadedListing = await listingFuture;
      final loadedUserId = await userIdFuture;

      User? loadedOwner;
      if (loadedListing.userIdFk.isNotEmpty) {
        try {
          loadedOwner = await UserServices().getUserWithId(loadedListing.userIdFk);
        } catch (e) {
          loadedOwner = null;
        }
      }

      List<BookedRange> loadedBookings;
      try {
        loadedBookings = await bookingsFuture;
      } catch (e) {
        loadedBookings = [];
      }

      List<DressDamageIncident> loadedIncidents;
      try {
        loadedIncidents = await damageIncidentsFuture;
      } catch (e) {
        loadedIncidents = [];
      }

      final loadedVariants = await _loadSizeVariants(loadedListing);

      if (generation != _requestGeneration) return;
      listing = loadedListing;
      currentUserId = loadedUserId;
      listingOwner = loadedOwner;
      bookings = loadedBookings;
      damageIncidents = loadedIncidents;
      sizeVariants = loadedVariants;
    } catch (e) {
      if (generation != _requestGeneration) return;
      listing = null;
      listingOwner = null;
      bookings = [];
      damageIncidents = [];
      sizeVariants = [];
      currentUserId = null;
    } finally {
      // Only the latest load settles the flags: a superseded load finishing
      // early must not hide the spinner of the one still in flight.
      if (generation == _requestGeneration) {
        isLoading = false;
        isSwitchingSize = false;
        notifyListeners();
      }
    }
  }

  Future<List<Listing>> _loadSizeVariants(Listing current) async {
    try {
      final result = await DressServices().getPublicDresses(
        allQueries: {
          'userId': current.userIdFk,
          'brand': current.brand,
          'style': current.style,
          'limit': '20',
          // Bypass the Browse-feed grouping — this lookup needs every size
          // row for the switcher, not one representative row per group.
          'ungrouped': 'true',
        },
      );
      final variants = result.data.toList();
      if (!variants.any((l) => l.id == current.id)) variants.add(current);
      variants.sort((a, b) {
        final rankA = sizeRank(a.size);
        final rankB = sizeRank(b.size);
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.size.compareTo(b.size);
      });
      return variants;
    } catch (e) {
      return [current];
    }
  }

  // Switches the active listing to the size variant matching [size], without
  // triggering the full-page loading skeleton. getListing clears
  // isSwitchingSize once the latest load settles.
  Future<void> selectSize(String size) async {
    final match = sizeVariants.where((l) => l.size == size);
    if (match.isEmpty) return;
    final target = match.first;
    if (target.id == listing?.id) return;

    isSwitchingSize = true;
    notifyListeners();
    await getListing(target.id, silent: true);
  }

  void reset() {
    _requestGeneration++;
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
