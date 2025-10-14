import 'package:flutter/material.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/services/user_services.dart';

class AuthProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  // State properties
  bool isLoading = false;
  bool isSignedIn = false;
  String signInErrorMessage = '';
  String signUpErrorMessage = '';
  String signUpMessage = '';
  bool signUpSuccess = false;
  String forgotPasswordMessage = '';
  bool forgotPasswordSuccess = false;
  String resetPasswordMessage = '';
  bool resetPasswordSuccess = false;
  String changePasswordMessage = '';
  bool changePasswordSuccess = false;

  /// Check if user is authenticated on app startup
  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      isSignedIn = await _userServices.checkAuthenticationStatus();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      isSignedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up a new user and automatically sign them in
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
    signUpMessage = '';
    signUpSuccess = false;
    notifyListeners();

    try {
      await _userServices.signUpAndSignIn(
        firstName,
        lastName,
        username,
        email,
        password,
        phoneNumber,
      );

      signUpSuccess = true;
      signUpMessage = 'Account created successfully!';
      isSignedIn = true;
    } on AuthException catch (e) {
      signUpErrorMessage = e.message;
    } on DataParseException catch (e) {
      signUpErrorMessage = 'Data error: ${e.message}';
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

  /// Sign in an existing user
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    signInErrorMessage = '';
    notifyListeners();

    try {
      await _userServices.signIn(email, password);
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

  /// Sign out the current user
  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await _userServices.signOut();
    } catch (e) {
      // Log errors but always sign out locally even if API call fails
      debugPrint('Error during sign out: $e');
    } finally {
      isSignedIn = false;
      isLoading = false;
      notifyListeners();
    }
  }

  /// Request a password reset email
  Future<void> forgotPassword(String email) async {
    isLoading = true;
    forgotPasswordMessage = '';
    forgotPasswordSuccess = false;
    notifyListeners();

    try {
      await _userServices.forgotPassword(email);
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

  /// Reset password using a reset token
  Future<void> resetPassword(String newPassword) async {
    isLoading = true;
    resetPasswordMessage = '';
    resetPasswordSuccess = false;
    notifyListeners();

    try {
      await _userServices.resetPassword(newPassword);
      resetPasswordSuccess = true;
      resetPasswordMessage = 'Your password has been reset successfully.';
    } on UnauthenticatedException catch (e) {
      resetPasswordMessage = e.message;
    } on AuthException catch (e) {
      resetPasswordMessage = e.message;
    } on NetworkException catch (e) {
      resetPasswordMessage = 'Network error: ${e.message}';
    } catch (e) {
      resetPasswordMessage = 'Unexpected error during password reset';
      debugPrint('Reset password error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Change password for authenticated user
  Future<void> changePassword(String newPassword) async {
    isLoading = true;
    changePasswordMessage = '';
    changePasswordSuccess = false;
    notifyListeners();

    try {
      await _userServices.changePassword(newPassword);
      changePasswordSuccess = true;
      changePasswordMessage = 'Your password has been changed successfully.';
    } on UnauthenticatedException catch (e) {
      changePasswordMessage = e.message;
    } on AuthException catch (e) {
      changePasswordMessage = e.message;
    } on NetworkException catch (e) {
      changePasswordMessage = 'Network error: ${e.message}';
    } catch (e) {
      changePasswordMessage = 'Unexpected error during password change';
      debugPrint('Change password error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // The following methods are used by the UI to clear state when navigating away from certain pages

  void clearChangePasswordState() {
    changePasswordMessage = '';
    changePasswordSuccess = false;
  }

  void clearSignUpState() {
    signUpMessage = '';
    signUpSuccess = false;
    signUpErrorMessage = '';
  }

  void clearForgotPasswordState() {
    forgotPasswordMessage = '';
    forgotPasswordSuccess = false;
  }

  void clearResetPasswordState() {
    resetPasswordMessage = '';
    resetPasswordSuccess = false;
  }
}
