import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';
import 'package:motorix_app/data/services/vehicle_notification_service.dart';

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
      _errorMessage =
          'An unexpected error occurred while loading your vehicles.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicle(
    int vehicleId,
    Map<String, Object> updates,
  ) async {
    try {
      await VehicleServices().updateVehicle(vehicleId, updates);

      // Refresh the vehicle list to get updated data
      await fetchVehicles();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update vehicle: ${e.toString()}');
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    try {
      // Delete vehicle from backend
      await VehicleServices().deleteVehicle(vehicleId, {});

      // Cancel all scheduled notifications for this vehicle
      // This should not block deletion if it fails
      try {
        await VehicleNotificationService().cancelVehicleNotifications(vehicleId);
      } catch (e) {
        // Log the error but don't fail the deletion
        debugPrint('Failed to cancel notifications for vehicle $vehicleId: $e');
      }

      // Remove the vehicle from the local list
      _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete vehicle: ${e.toString()}');
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
