import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/presentation/widgets/listing_form/listing_form_data_provider.dart';

class EditListingProvider extends ChangeNotifier
    implements ListingFormDataProvider {
  EditListingProvider(this.listing) {
    _loadAttributes();
    _initializeData();
  }

  final Listing listing;
  bool isLoading = false;
  bool attributesLoaded = false;
  bool successfulUpdate = false;
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];
  final Map<String, Object> editListingData = {};

  @override
  Map<String, Object> get formData => editListingData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
      attributesLoaded = true;
    } catch (e) {
      if (e is AppException) {
        debugPrint('Error loading filters: ${e.message}');
      } else {
        debugPrint('Error loading filters: $e');
      }
      attributesLoaded = true; // Set to true even on error to show the form
    } finally {
      notifyListeners();
    }
  }

  void _initializeData() {
    // Initialize with existing listing data
    editListingData['location'] = listing.location;
    editListingData['vehicleCondition'] = listing.vehicleCondition;
    editListingData['price'] = listing.price;
    editListingData['description'] = listing.description;
    editListingData['endDate'] = listing.endDate.toIso8601String().split('T')[0];
    editListingData['make'] = listing.make;
    editListingData['model'] = listing.model;
    editListingData['year'] = listing.year;
    editListingData['kilometers'] = listing.kilometers;
    editListingData['fuelType'] = listing.fuelType;
    editListingData['bodyType'] = listing.bodyType;
    editListingData['driveType'] = listing.driveType;

    // Optional fields
    if (listing.orcIncluded != null) {
      editListingData['orcIncluded'] = listing.orcIncluded!;
    }
    if (listing.numberPlate != null) {
      editListingData['numberPlate'] = listing.numberPlate!;
    }
    if (listing.seats != null) {
      editListingData['seats'] = listing.seats!;
    }
    if (listing.doors != null) {
      editListingData['doors'] = listing.doors!;
    }
    if (listing.previousOwners != null) {
      editListingData['previousOwners'] = listing.previousOwners!;
    }
    if (listing.color != null) {
      editListingData['color'] = listing.color!;
    }
    if (listing.engineSize != null) {
      editListingData['engineSize'] = listing.engineSize!;
    }
    if (listing.transmission != null) {
      editListingData['transmission'] = listing.transmission!;
    }
    if (listing.cylinders != null) {
      editListingData['cylinders'] = listing.cylinders!;
    }
    if (listing.regoExpiryDate != null) {
      editListingData['regoExpiryDate'] =
          listing.regoExpiryDate!.toIso8601String().split('T')[0];
    }
    if (listing.wofExpiryDate != null) {
      editListingData['wofExpiryDate'] =
          listing.wofExpiryDate!.toIso8601String().split('T')[0];
    }
  }

  void resetProvider() {
    isLoading = false;
    successfulUpdate = false;
    errorMessage = '';
    _initializeData(); // Reset to original listing data
  }

  Future<void> updateListing(String userId) async {
    isLoading = true;
    errorMessage = '';
    successfulUpdate = false;
    notifyListeners();

    try {
      editListingData['currentUserId'] = userId;

      await ListingsServices().patchListing(
        listing.id,
        editListingData,
      );

      successfulUpdate = true;
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to update listing';
        debugPrint('Update listing error: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
