import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
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

      if (listing?.userIdFk != null && listing!.userIdFk.isNotEmpty) {
        try {
          listingOwner = await UserServices().getUserWithId(listing!.userIdFk);
        } catch (e) {
          listingOwner = null;
        }
      }
    } catch (e) {
      listing = null;
      listingOwner = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
