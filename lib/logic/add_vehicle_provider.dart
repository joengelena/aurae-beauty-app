import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class AddVehicleProvider extends ChangeNotifier
    implements ListingFormDataProvider {
  AddVehicleProvider() {
    _loadAttributes();
  }

  final Map<String, Object> _formData = {};
  bool isLoading = false;
  bool successfulPost = false;
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];

  // Vehicle image data
  Uint8List? vehicleImageBytes;
  String? vehicleImageMimeType;

  @override
  Map<String, Object> get formData => _formData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
    } catch (e) {
      if (e is AppException) {
        debugPrint('Error loading filters: ${e.message}');
      } else {
        debugPrint('Error loading filters: $e');
      }
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

  void setVehicleImage(Uint8List imageBytes, String mimeType) {
    vehicleImageBytes = imageBytes;
    vehicleImageMimeType = mimeType;
    notifyListeners();
  }

  void removeVehicleImage() {
    vehicleImageBytes = null;
    vehicleImageMimeType = null;
    notifyListeners();
  }

  Future<void> addVehicle() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Get current user ID
      final userId = await SecureStorage.read('userId');
      if (userId == null || userId.isEmpty) {
        throw AppException('User not authenticated');
      }

      // Prepare the data for the API
      final vehicleData = Map<String, dynamic>.from(_formData);
      vehicleData['currentUserId'] = userId;

      // Call the API with optional image
      await VehicleServices().addVehicle(
        vehicleData,
        imageBytes: vehicleImageBytes,
        imageMimeType: vehicleImageMimeType,
      );

      successfulPost = true;
    } on AppException catch (e) {
      errorMessage = e.message;
      successfulPost = false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
      successfulPost = false;
      debugPrint('Error adding vehicle: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetProvider() {
    _formData.clear();
    vehicleImageBytes = null;
    vehicleImageMimeType = null;
    isLoading = false;
    successfulPost = false;
    errorMessage = '';
    notifyListeners();
  }
}
