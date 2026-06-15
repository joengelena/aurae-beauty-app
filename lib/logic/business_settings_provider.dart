import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_settings.dart';
import 'package:shine_app/data/services/user_services.dart';

class BusinessSettingsProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  BusinessSettings _settings = const BusinessSettings();
  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';

  BusinessSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _settings = await _userServices.getBusinessSettings();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save(BusinessSettings updated) async {
    _isSaving = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _settings = await _userServices.updateBusinessSettings(updated);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Failed to save settings.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
