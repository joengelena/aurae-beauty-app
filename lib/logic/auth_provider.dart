import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/services/user_services.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> isSignedIn() async {
    String? authToken = await SecureStorage.read('authToken');

    if (authToken == null) {
      return false;
    }

    return true;
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
    notifyListeners();

    ApiResponse response = await UserServices().signIn(email, password);

    if (!response.isSuccess) {
      isLoading = false;
      // Failed to sign in
      notifyListeners();
      return;
    }

    isLoading = false;
    notifyListeners();
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

    isLoading = false;
    notifyListeners();
  }
}
