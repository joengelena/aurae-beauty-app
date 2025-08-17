import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/data/services/user_services.dart';

class ListingDetailProvider extends ChangeNotifier {
  ListingDetailProvider();

  Listing? listing;
  User? listingOwner;
  bool isLoading = false;

  Future<void> getListing(int listingId) async {
    try {
      isLoading = true;
      notifyListeners();

      listing = await ListingsServices().getListing(listingId);
      ApiResponse<User> userResponse = await UserServices().getUserWithId(
        listing?.userIdFk ?? '',
      );

      if (!userResponse.isSuccess) {
        // Failed to get user
        isLoading = false;
        notifyListeners();
      }

      listingOwner = userResponse.data;
    } catch (e) {
      debugPrint('Error loading listings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
