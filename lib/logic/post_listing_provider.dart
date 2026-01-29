import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:motorix_app/logic/listing_image_picker_mixin.dart';

class PostListingProvider extends ChangeNotifier
    with ListingImagePickerMixin
    implements ListingFormDataProvider {
  PostListingProvider() {
    _loadAttributes();
  }

  int? newListingId;
  bool isLoading = false;
  bool successfulPost = false;
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];
  final optionalDropdownFields = ['transmission', 'cylinders'];
  final Map<String, Object> postListingData = {};
  bool _isSignedIn = false;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      resetProvider();
    }
    _isSignedIn = isSignedIn;
  }

  void setDefaultLocation(String? userLocation) {
    if (userLocation != null && !postListingData.containsKey('location')) {
      postListingData['location'] = userLocation;
    }
  }

  @override
  Map<String, Object> get formData => postListingData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
      // Add 'None' option to optional dropdown fields
      for (var attributeWithoutNone in listingAttributeOptions) {
        if (optionalDropdownFields.contains(attributeWithoutNone.name)) {
          attributeWithoutNone.attributeValues.insert(0, 'None');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load listing attributes: $e');
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

  @override
  Future<String?> pickImage() async {
    final error = await super.pickImage();
    notifyListeners();
    return error;
  }

  @override
  void removeImage(int index) {
    super.removeImage(index);
    notifyListeners();
  }

  bool validatePostListingFields() {
    return true;
  }

  void resetProvider() {
    newListingId = null;
    isLoading = false;
    successfulPost = false;
    errorMessage = '';
    postListingData.clear();
    clearImages();
    notifyListeners();
  }

  Map<String, Object> _filterNoneValues() {
    return Map.fromEntries(
      postListingData.entries.where((entry) => entry.value != 'None'),
    );
  }

  Future<void> postListing() async {
    isLoading = true;
    errorMessage = '';
    successfulPost = false;
    notifyListeners();

    try {
      final images = await buildMultipartFiles();

      final filteredData = _filterNoneValues();

      final result = await ListingsServices().postListing(filteredData, images);

      newListingId = result['listingId'] as int?;
      successfulPost = true;
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to post listing';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
