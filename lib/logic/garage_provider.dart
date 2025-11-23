import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';

class GarageProvider extends ChangeNotifier {
  List<UserVehicle> _vehicles = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  List<UserVehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  void updateAuthStatus(bool isSignedIn) async {
    if (isSignedIn && !_isSignedIn) {
      // User just signed in, fetch their vehicles
      await fetchVehicles();
    } else if (!isSignedIn && _isSignedIn) {
      // User signed out, clear vehicles
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _vehicles = await VehicleServices().getAllVehicles();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading your vehicles.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void reset() {
    _vehicles = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
