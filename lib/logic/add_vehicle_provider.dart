import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';
import 'package:motorix_app/presentation/widgets/listing_form/listing_form_data_provider.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class AddVehicleProvider extends ChangeNotifier
    implements ListingFormDataProvider {
  final Map<String, Object> _formData = {};
  bool isLoading = false;
  bool successfulPost = false;
  String errorMessage = '';

  @override
  Map<String, Object> get formData => _formData;

  @override
  List<ListingAttribute> get listingAttributeOptions => [];

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

      // Call the API
      await VehicleServices().addVehicle(vehicleData);

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
    isLoading = false;
    successfulPost = false;
    errorMessage = '';
    notifyListeners();
  }
}
