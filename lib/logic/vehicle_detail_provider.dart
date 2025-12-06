import 'package:flutter/foundation.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';

class VehicleDetailProvider extends ChangeNotifier {
  final VehicleServices _vehicleServices = VehicleServices();

  UserVehicle? _vehicle;
  bool _isLoading = false;
  String? _errorMessage;

  UserVehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> getVehicle(int vehicleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicle = await _vehicleServices.getVehicleById(vehicleId);
      _errorMessage = null;
    } on NotFoundException catch (e) {
      _errorMessage = e.message;
      _vehicle = null;
    } on ForbiddenException catch (e) {
      _errorMessage = e.message;
      _vehicle = null;
    } catch (e) {
      _errorMessage = 'Failed to load vehicle details. Please try again.';
      _vehicle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearVehicle() {
    _vehicle = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
