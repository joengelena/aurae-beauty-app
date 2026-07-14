import 'package:flutter/material.dart';
import 'package:shine_app/data/cache_manager.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/services/user_services.dart';
import 'package:shine_app/utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  // State properties
  bool isLoading = false;
  bool isSignedIn = false;
  bool isAuthInitialized = false; // Track if initial auth check completed
  String signInErrorMessage = '';
  String signUpErrorMessage = '';
  String signUpMessage = '';
  bool signUpSuccess = false;
  bool isResendingVerificationEmail = false;
  String forgotPasswordMessage = '';
  bool forgotPasswordSuccess = false;
  String resetPasswordMessage = '';
  bool resetPasswordSuccess = false;
  String changePasswordMessage = '';
  bool changePasswordSuccess = false;

  bool get isEmailNotVerifiedError =>
      signInErrorMessage.contains('verify your email');

  /// Quick check to see if user has stored tokens (without API call)
  /// Used to detect if this is a page refresh vs cold start
  Future<bool> hasStoredTokens() async {
    try {
      final userId = await SecureStorage.read('userId');
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated on app startup
  /// Sets isLoading=true during check, isAuthInitialized=true when complete
  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();

    try {
      isSignedIn = await _userServices.checkAuthenticationStatus();
    } catch (e) {
      isSignedIn = false;
    } finally {
      isAuthInitialized = true;
      isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up a new user (email verification required before sign in)
  Future<void> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String location,
  ) async {
    isLoading = true;
    signUpErrorMessage = '';
    signUpMessage = '';
    signUpSuccess = false;
    notifyListeners();

    try {
      final response = await _userServices.signUp(
        firstName,
        lastName,
        email,
        password,
        phoneNumber,
        location,
      );

      signUpSuccess = true;
      signUpMessage = response['message'] ?? 'Account created successfully!';
    } catch (e) {
      if (e is AppException) {
        signUpErrorMessage = e.message;
      } else {
        signUpErrorMessage = 'Unexpected error occurred';
      }
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
      isAuthInitialized = true;
    } catch (e) {
      if (e is AppException) {
        signInErrorMessage = e.message;
      } else {
        signInErrorMessage = 'Unexpected error occurred';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Resend verification email to the user
  Future<void> resendVerificationEmail(String email) async {
    isResendingVerificationEmail = true;
    notifyListeners();

    try {
      await _userServices.resendVerificationEmail(email);
    } finally {
      isResendingVerificationEmail = false;
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
      // Silently handle sign out errors - always sign out locally even if API call fails
      debugPrint('⚠️ Failed to sign out (continuing with local sign out): $e');
    } finally {
      try {
        await CacheManager.instance.clearCache();
        debugPrint('✅ Cache cleared on sign out');
      } catch (e) {
        debugPrint('⚠️ Failed to clear cache on sign out: $e');
      }

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
    } catch (e) {
      if (e is AppException) {
        forgotPasswordMessage = e.message;
      } else {
        forgotPasswordMessage = 'Unexpected error occurred';
      }
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
    } catch (e) {
      if (e is AppException) {
        resetPasswordMessage = e.message;
      } else {
        resetPasswordMessage = 'Unexpected error occurred';
      }
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
    } catch (e) {
      if (e is AppException) {
        changePasswordMessage = e.message;
      } else {
        changePasswordMessage = 'Unexpected error occurred';
      }
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

  void clearSignInState() {
    signInErrorMessage = '';
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
