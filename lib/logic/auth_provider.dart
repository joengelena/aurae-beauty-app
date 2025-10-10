import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/services/user_services.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSignedIn = false;
  String signInErrorMessage = '';

  /// Check if user is already authenticated on app start
  /// Attempts to refresh the session using refresh token
  /// For mobile: uses refreshToken from secure storage
  /// For web: uses refreshToken cookie automatically sent by browser
  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = await SecureStorage.read('userId');

      if (userId != null && userId.isNotEmpty) {
        // Attempt to refresh the session silently
        // This validates that the refresh token is still valid
        final refreshSuccess = await UserServices().refreshSession();

        if (refreshSuccess) {
          // Session refreshed successfully, user is authenticated
          isSignedIn = true;
        } else {
          // Refresh failed (token expired or invalid), clear stored data
          await _clearStoredAuthData();
          isSignedIn = false;
        }
      } else {
        // No userId stored, user is not authenticated
        isSignedIn = false;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      await _clearStoredAuthData();
      isSignedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear stored authentication data
  /// Helper method for checkAuthStatus when refresh fails
  Future<void> _clearStoredAuthData() async {
    try {
      await SecureStorage.delete('userId');

      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    } catch (e) {
      debugPrint('Error clearing stored auth data: $e');
    }
  }

  Future<void> signUp(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    isLoading = true;
    notifyListeners();

    ApiResponse response = await UserServices().signUp(
      firstName,
      lastName,
      username,
      email,
      password,
      phoneNumber,
    );

    if (!response.isSuccess) {
      isLoading = false;
      // Failed to sign out
      notifyListeners();
      return;
    }

    signIn(email, password);
  }

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    signInErrorMessage = ''; // Clear previous errors
    notifyListeners();

    ApiResponse response = await UserServices().signIn(email, password);

    if (!response.isSuccess && response.error != null) {
      signInErrorMessage = response.error ?? 'Error signing in';
      isLoading = false;
      notifyListeners();
      return;
    }

    isSignedIn = true;
    isLoading = false;
    notifyListeners();
    return;
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    ApiResponse response = await UserServices().signOut();

    if (!response.isSuccess) {
      isLoading = false;
      // Failed to sign out
      notifyListeners();
      return;
    }

    isSignedIn = false;
    isLoading = false;
    notifyListeners();
  }
}
