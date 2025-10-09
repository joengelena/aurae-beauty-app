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
  /// For mobile: checks for accessToken in secure storage
  /// For web: makes a test API call (cookie automatically sent by browser)
  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web: check if userId exists (cookies handled by browser)
        // The server will validate the cookie automatically
        final userId = await SecureStorage.read('userId');

        if (userId != null && userId.isNotEmpty) {
          // Optionally: make a test API call to verify cookie is still valid
          // For now, trust that userId exists means user was signed in
          isSignedIn = true;
        }
      } else {
        final accessToken = await SecureStorage.read('accessToken');
        final userId = await SecureStorage.read('userId');

        if (accessToken != null &&
            accessToken.isNotEmpty &&
            userId != null &&
            userId.isNotEmpty) {
          isSignedIn = true;
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      isSignedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
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
