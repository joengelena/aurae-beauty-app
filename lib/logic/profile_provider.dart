import 'dart:typed_data';
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
  String updateMessage = '';
  String updateErrorMessage = '';
  bool updateSuccess = false;

  // Profile photo state
  Uint8List? profilePhotoBytes;
  String? profilePhotoMimeType;
  bool _isPhotoChanged = false;

  bool get isPhotoChanged => _isPhotoChanged;

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

  void setProfilePhoto(Uint8List imageBytes, String mimeType) {
    profilePhotoBytes = imageBytes;
    profilePhotoMimeType = mimeType;
    _isPhotoChanged = true;
    notifyListeners();
  }

  void removeProfilePhoto() {
    profilePhotoBytes = null;
    profilePhotoMimeType = null;
    _isPhotoChanged = false;
    notifyListeners();
  }

  Future<void> updateUserProfile(
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    isLoading = true;
    updateErrorMessage = '';
    updateMessage = '';
    updateSuccess = false;
    notifyListeners();

    try {
      final userId = await SecureStorage.read('userId') ?? '';
      await _userServices.updateUser(
        firstName,
        lastName,
        phoneNumber,
        userId,
        imageBytes: _isPhotoChanged ? profilePhotoBytes : null,
        imageMimeType: _isPhotoChanged ? profilePhotoMimeType : null,
      );

      await _fetchCurrentUserProfile();

      // Clear photo state after successful upload
      profilePhotoBytes = null;
      profilePhotoMimeType = null;
      _isPhotoChanged = false;

      updateSuccess = true;
      updateMessage = 'Profile updated successfully!';
    } catch (e) {
      if (e is AppException) {
        updateErrorMessage = e.message;
      } else {
        updateErrorMessage = 'Failed to update profile';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearUpdateState() {
    updateMessage = '';
    updateSuccess = false;
    updateErrorMessage = '';
    profilePhotoBytes = null;
    profilePhotoMimeType = null;
    _isPhotoChanged = false;
    notifyListeners();
  }
}
