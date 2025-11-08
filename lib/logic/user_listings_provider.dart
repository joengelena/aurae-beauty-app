import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class UserListingsProvider extends ChangeNotifier {
  UserListingsProvider();

  final List<Listing> userListings = [];
  final int limit = 10;
  int currentPage = 0;
  int totalPages = 1;
  int totalListings = 0;
  bool isLoading = false;
  String errorMessage = '';
  String? _currentUserId;

  bool get onLastPage => currentPage >= totalPages;
  bool get canLoadMore => !onLastPage && !isLoading;
  bool get hasListings => userListings.isNotEmpty;

  Future<void> fetchUserListings(String userId) async {
    _currentUserId = userId;
    userListings.clear();
    currentPage = 0;
    await _loadListings();
  }

  Future<void> loadMoreListings() async {
    if (_currentUserId != null && canLoadMore) {
      await _loadListings();
    }
  }

  Future<void> _loadListings() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final resp = await ListingsServices().getAllListings(
        allQueries: {
          'limit': limit,
          'pageNumber': currentPage + 1,
          'userIdFk': _currentUserId!,
        },
      );

      userListings.addAll(resp.data);
      totalPages = resp.totalPages;
      currentPage = resp.pageNumber;
      totalListings = resp.totalRows;
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
        debugPrint('Error loading user listings: ${e.message}');
      } else {
        errorMessage = 'Failed to load listings';
        debugPrint('Error loading user listings: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void removeListing(int listingId) {
    userListings.removeWhere((listing) => listing.id == listingId);
    totalListings = totalListings - 1;
    notifyListeners();
  }

  Future<void> _updateListingStatus(int listingId, String status) async {
    try {
      final userId = await SecureStorage.read('userId');
      if (userId == null) {
        throw AppException('User not authenticated');
      }

      await ListingsServices().patchListing(
        listingId,
        {
          'currentUserId': userId,
          'status': status,
        },
      );

      // Update the local listing status
      final index = userListings.indexWhere((listing) => listing.id == listingId);
      if (index != -1) {
        userListings[index] = userListings[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update listing status: ${e.toString()}');
    }
  }

  Future<void> markAsSold(int listingId) async {
    await _updateListingStatus(listingId, 'sold');
  }

  Future<void> markAsActive(int listingId) async {
    await _updateListingStatus(listingId, 'active');
  }

  void clearListings() {
    userListings.clear();
    currentPage = 0;
    totalPages = 1;
    totalListings = 0;
    errorMessage = '';
    _currentUserId = null;
    notifyListeners();
  }
}
