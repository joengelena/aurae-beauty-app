import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';
import 'package:motorix_app/logic/vehicle_form_provider.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class EditVehicleProvider extends ChangeNotifier
    implements VehicleFormProvider {
  final int vehicleId;

  EditVehicleProvider(this.vehicleId) {
    _loadAttributes();
    _loadVehicle();
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

  // Original vehicle data for reference
  UserVehicle? originalVehicle;

  @override
  Map<String, Object> get formData => _formData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
    } catch (e) {
      // Silently handle attribute loading errors
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadVehicle() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      originalVehicle = await VehicleServices().getVehicleById(vehicleId);
      _populateFormData(originalVehicle!);

      // Load existing vehicle image if available
      if (originalVehicle!.vehiclePhotoUrl != null &&
          originalVehicle!.vehiclePhotoUrl!.isNotEmpty) {
        await _loadVehicleImage(originalVehicle!.vehiclePhotoUrl!);
      }
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load vehicle data. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _populateFormData(UserVehicle vehicle) {
    _formData['make'] = vehicle.make;
    _formData['model'] = vehicle.model;
    _formData['year'] = vehicle.year;
    _formData['odometerUnit'] = vehicle.odometerUnit;
    _formData['regoExpiryDate'] = vehicle.regoExpiryDate;
    _formData['wofExpiryDate'] = vehicle.wofExpiryDate;

    // Optional fields - only add if not null
    if (vehicle.licensePlate != null) {
      _formData['licensePlate'] = vehicle.licensePlate!;
    }
    if (vehicle.color != null) _formData['color'] = vehicle.color!;
    if (vehicle.fuelType != null) _formData['fuelType'] = vehicle.fuelType!;
    if (vehicle.transmission != null) {
      _formData['transmission'] = vehicle.transmission!;
    }
    if (vehicle.odometerReading != null) {
      _formData['odometerReading'] = vehicle.odometerReading!;
    }
    if (vehicle.notes != null) _formData['notes'] = vehicle.notes!;
  }

  /// Fetches the vehicle image from the URL and converts it to bytes for preview.
  Future<void> _loadVehicleImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        vehicleImageBytes = response.bodyBytes;
        String? contentType = response.headers['content-type'];
        vehicleImageMimeType = contentType;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - image preview is not critical for editing other fields
      // User can still update vehicle data even if image fails to load
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
      final vehicleData = Map<String, Object>.from(_formData);
      vehicleData['currentUserId'] = userId;

      // Call the API to update vehicle
      // Note: Current API doesn't support image updates in PATCH
      // Image updates would require additional API endpoint or multipart support
      await VehicleServices().updateVehicle(vehicleId, vehicleData);

      isSuccess = true;
    } on AppException catch (e) {
      errorMessage = e.message;
      isSuccess = false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
      isSuccess = false;
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
    isSuccess = false;
    errorMessage = '';
    originalVehicle = null;
    notifyListeners();
  }
}
