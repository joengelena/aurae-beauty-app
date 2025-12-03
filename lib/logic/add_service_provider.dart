import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/service_form_provider.dart';
import 'package:motorix_app/utils/secure_storage.dart';

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
      serviceData['vehicleIdFk'] = _vehicle.id; // Match DB column name

      // TODO: Replace with actual service record API call when backend is ready
      // Example: await VehicleServices().addServiceRecord(serviceData);
      // Expected payload:
      // {
      //   "vehicleIdFk": int,
      //   "typeOfService": string (required, max 150 chars),
      //   "serviceDate": string (required, format: "YYYY-MM-DD"),
      //   "serviceProviderName": string (optional, max 150 chars),
      //   "cost": double (optional, >= 0),
      //   "notes": string (optional, TEXT),
      //   "currentUserId": string (for auth)
      // }

      // For now, simulate the API call
      await Future.delayed(const Duration(seconds: 1));

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
    isLoading = false;
    isSuccess = false;
    errorMessage = '';
    notifyListeners();
  }
}
