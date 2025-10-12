import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/services/user_services.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSignedIn = false;
  String signInErrorMessage = '';
  String signUpErrorMessage = '';
  String forgotPasswordMessage = '';
  bool forgotPasswordSuccess = false;

  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = await SecureStorage.read('userId');

      if (userId != null && userId.isNotEmpty) {
        try {
          await UserServices().refreshSession();
          isSignedIn = true;
        } on UnauthenticatedException catch (e) {
          debugPrint('Unauthenticated on startup: ${e.message}');
          await _clearStoredAuthData();
          isSignedIn = false;
        } on AuthException catch (e) {
          debugPrint('Auth error on startup: ${e.message}');
          await _clearStoredAuthData();
          isSignedIn = false;
        } on NetworkException catch (e) {
          debugPrint('Network error on startup: ${e.message}');
          isSignedIn = true;
        }
      } else {
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
    signUpErrorMessage = '';
    notifyListeners();

    try {
      await UserServices().signUp(
        firstName,
        lastName,
        username,
        email,
        password,
        phoneNumber,
      );

      await signIn(email, password);
    } on AuthException catch (e) {
      signUpErrorMessage = e.message;
    } on NetworkException catch (e) {
      signUpErrorMessage = 'Network error: ${e.message}';
    } catch (e) {
      signUpErrorMessage = 'Unexpected error during sign up';
      debugPrint('Sign up error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    signInErrorMessage = '';
    notifyListeners();

    try {
      await UserServices().signIn(email, password);
      isSignedIn = true;
    } on AuthException catch (e) {
      signInErrorMessage = e.message;
    } on DataParseException catch (e) {
      signInErrorMessage = 'Data error: ${e.message}';
    } on NetworkException catch (e) {
      signInErrorMessage = 'Network error: ${e.message}';
    } catch (e) {
      signInErrorMessage = 'Unexpected error during sign in';
      debugPrint('Sign in error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await UserServices().signOut();
    } on UnauthenticatedException catch (e) {
      debugPrint('Unauthenticated during sign out: ${e.message}');
    } on AuthException catch (e) {
      debugPrint('Auth error during sign out: ${e.message}');
    } on NetworkException catch (e) {
      debugPrint('Network error during sign out: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during sign out: $e');
    } finally {
      isSignedIn = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    isLoading = true;
    forgotPasswordMessage = '';
    forgotPasswordSuccess = false;
    notifyListeners();

    try {
      await UserServices().forgotPassword(email);
      forgotPasswordSuccess = true;
      forgotPasswordMessage =
          'If an account exists with this email, a password reset link has been sent.';
    } on AuthException catch (e) {
      forgotPasswordMessage = e.message;
    } on NetworkException catch (e) {
      forgotPasswordMessage = 'Network error: ${e.message}';
    } catch (e) {
      forgotPasswordMessage = 'Unexpected error during password reset request';
      debugPrint('Forgot password error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
