import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';

class GarageProvider extends ChangeNotifier {
  List<UserVehicle> _vehicles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<UserVehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  UserVehicle? get primaryVehicle {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.isPrimary == 1);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchVehicles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _vehicles = await VehicleServices().getAllVehicles();
    } on AppException catch (e) {
      _errorMessage = e.message;
      debugPrint('Error fetching vehicles: ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading your vehicles.';
      debugPrint('Unexpected error fetching vehicles: $e');
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
