import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/listing_attribute.dart';
import 'package:shine_app/data/models/user_vehicle.dart';
import 'package:shine_app/data/services/listings_services.dart';
import 'package:shine_app/data/services/vehicle_services.dart';
import 'package:shine_app/data/services/vehicle_notification_service.dart';
import 'package:shine_app/logic/vehicle_form_provider.dart';
import 'package:shine_app/utils/secure_storage.dart';

class AddVehicleProvider extends ChangeNotifier
    implements VehicleFormProvider {
  AddVehicleProvider() {
    _loadAttributes();
  }

  final Map<String, Object> _formData = {};
  @override
  bool isLoading = false;
  @override
  bool isSuccess = false;
  @override
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];

  // Vehicle image data
  @override
  Uint8List? vehicleImageBytes;
  @override
  String? vehicleImageMimeType;

  @override
  Map<String, Object> get formData => _formData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
    } catch (e) {
      debugPrint('⚠️ Failed to load listing attributes: $e');
    } finally {
      notifyListeners();
    }
  }

  @override
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
  void setVehicleImage(Uint8List imageBytes, String mimeType) {
    vehicleImageBytes = imageBytes;
    vehicleImageMimeType = mimeType;
    notifyListeners();
  }

  @override
  void removeVehicleImage() {
    vehicleImageBytes = null;
    vehicleImageMimeType = null;
    notifyListeners();
  }

  @override
  Future<void> submitForm() async {
    isLoading = true;
    errorMessage = '';
    isSuccess = false;
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
      final responseData = await VehicleServices().addVehicle(
        vehicleData,
        imageBytes: vehicleImageBytes,
        imageMimeType: vehicleImageMimeType,
      );

      // Parse the created vehicle
      final createdVehicle = UserVehicle.fromJson(responseData['vehicle']);

      // Schedule notifications for the new vehicle
      await VehicleNotificationService().scheduleVehicleNotifications(createdVehicle);

      isSuccess = true;
    } on AppException catch (e) {
      errorMessage = e.message;
      isSuccess = false;
    } catch (e, stackTrace) {
      debugPrint('Error adding vehicle: $e\n$stackTrace');
      errorMessage = 'An unexpected error occurred. Please try again.';
      isSuccess = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Keep for backward compatibility
  Future<void> addVehicle() => submitForm();

  void resetProvider() {
    _formData.clear();
    vehicleImageBytes = null;
    vehicleImageMimeType = null;
    isLoading = false;
    isSuccess = false;
    errorMessage = '';
    notifyListeners();
  }
}
