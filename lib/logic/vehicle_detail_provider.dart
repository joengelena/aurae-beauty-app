import 'package:flutter/foundation.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/models/vehicle_service.dart';
import 'package:motorix_app/data/services/vehicle_services.dart';

class VehicleDetailProvider extends ChangeNotifier {
  final VehicleServices _vehicleServices = VehicleServices();

  UserVehicle? _vehicle;
  List<VehicleService> _services = [];
  bool _isLoading = false;
  bool _isLoadingServices = false;
  String? _errorMessage;

  UserVehicle? get vehicle => _vehicle;
  List<VehicleService> get services => _services;
  bool get isLoading => _isLoading;
  bool get isLoadingServices => _isLoadingServices;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> getVehicle(int vehicleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicle = await _vehicleServices.getVehicleById(vehicleId);
      _errorMessage = null;
      // Load services after vehicle is loaded
      await getServices(vehicleId);
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

  Future<void> getServices(int vehicleId) async {
    _isLoadingServices = true;
    notifyListeners();

    try {
      _services = await _vehicleServices.getServicesByVehicleId(vehicleId);
    } catch (e) {
      // Don't set error message for services failure
      // Just set empty list
      _services = [];
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  void clearVehicle() {
    _vehicle = null;
    _services = [];
    _errorMessage = null;
    _isLoading = false;
    _isLoadingServices = false;
    notifyListeners();
  }
}
