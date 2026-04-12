import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/user_vehicle.dart';
import 'package:shine_app/data/services/vehicle_services.dart';
import 'package:shine_app/logic/service_form_provider.dart';
import 'package:shine_app/utils/secure_storage.dart';

class AddServiceProvider extends ChangeNotifier implements ServiceFormProvider {
  AddServiceProvider({required UserVehicle vehicle}) : _vehicle = vehicle;

  final UserVehicle _vehicle;

  @override
  UserVehicle get vehicle => _vehicle;

  final Map<String, Object> _formData = {};

  @override
  bool isLoading = false;

  @override
  bool isSuccess = false;

  @override
  String errorMessage = '';

  @override
  Map<String, Object> get formData => _formData;

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

      // Prepare the data for the API (matching DB schema)
      final serviceData = Map<String, Object>.from(_formData);
      serviceData['currentUserId'] = userId;
      serviceData['vehicleIdFk'] = _vehicle.id;

      await VehicleServices().addServiceRecord(
        serviceData as Map<String, dynamic>,
      );

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
}
