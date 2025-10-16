import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/data/services/user_services.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class ProfileProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  bool isLoading = false;
  User? currentUser;
  String errorMessage = '';
  bool _isSignedIn = false;

  void updateAuthStatus(bool isSignedIn) {
    if (isSignedIn && !_isSignedIn) {
      _fetchCurrentUserProfile();
    } else if (!isSignedIn && _isSignedIn) {
      clearProfile();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> _fetchCurrentUserProfile() async {
    final userId = await SecureStorage.read('userId');
    if (userId != null && userId.isNotEmpty) {
      await fetchUserProfile(userId);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      currentUser = await _userServices.getUserWithId(userId);
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to load profile';
        debugPrint('Profile fetch error: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    currentUser = null;
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }
}
