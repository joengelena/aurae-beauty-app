import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:motorix_app/logic/listing_image_picker_mixin.dart';

class EditListingProvider extends ChangeNotifier
    with ListingImagePickerMixin
    implements ListingFormDataProvider {
  EditListingProvider(this.listing) {
    _loadAttributes();
    _initializeData();
    _loadExistingImages();
  }

  final Listing listing;
  bool isLoading = false;
  bool attributesLoaded = false;
  bool successfulUpdate = false;
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];
  final Map<String, Object> editListingData = {};

  // Track if user has changed images
  bool _imagesChanged = false;

  @override
  Map<String, Object> get formData => editListingData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
      attributesLoaded = true;
    } catch (e) {
      // Silently handle attribute loading errors
      attributesLoaded = true; // Set to true even on error to show the form
    } finally {
      notifyListeners();
    }
  }

  List<String> getAttributeValues(String attributeName) {
    try {
      return listingAttributeOptions
          .firstWhere((attr) => attr.name == attributeName)
          .attributeValues;
    } catch (e) {
      return [];
    }
  }

  void _initializeData() {
    // Initialize with existing listing data
    editListingData['location'] = listing.location;
    editListingData['vehicleCondition'] = listing.vehicleCondition;
    editListingData['originalPrice'] = listing.originalPrice;
    if (listing.discountedPrice != null) {
      editListingData['discountedPrice'] = listing.discountedPrice!;
    }
    editListingData['description'] = listing.description;
    editListingData['endDate'] =
        listing.endDate.toIso8601String().split('T')[0];
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

  /// Loads existing listing images from URLs for preview
  Future<void> _loadExistingImages() async {
    final imageUrls = listing.imageUrls.cast<String>();
    await loadImagesFromUrls(imageUrls);
    _imagesChanged = false; // Images loaded from server, not changed by user
    notifyListeners();
  }

  @override
  Future<String?> pickImage() async {
    final error = await super.pickImage();
    _imagesChanged = true; // User is adding images
    notifyListeners();
    return error;
  }

  @override
  void removeImage(int index) {
    super.removeImage(index);
    _imagesChanged = true; // User is modifying images
    notifyListeners();
  }

  void resetProvider() {
    isLoading = false;
    successfulUpdate = false;
    errorMessage = '';
    clearImages();
    _imagesChanged = false;
    _initializeData(); // Reset to original listing data
  }

  Future<void> updateListing(String userId) async {
    isLoading = true;
    errorMessage = '';
    successfulUpdate = false;
    notifyListeners();

    try {
      editListingData['currentUserId'] = userId;

      // Build image files if images were changed
      List<http.MultipartFile>? images;
      if (_imagesChanged && imageBytesList.isNotEmpty) {
        images = await buildMultipartFiles();
      }

      // Call API with optional images
      await ListingsServices().patchListing(
        listing.id,
        editListingData,
        images: images,
      );

      successfulUpdate = true;
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to update listing';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
