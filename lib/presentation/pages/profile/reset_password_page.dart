import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? accessToken;
  final String? resetType;
  final String? error;
  final String? errorCode;
  final String? errorDescription;

  const ResetPasswordPage({
    super.key,
    this.accessToken,
    this.resetType,
    this.error,
    this.errorCode,
    this.errorDescription,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isFormValid = false;
  bool hasValidToken = false;
  bool isExtractingToken = true;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);

    // Process the access token passed from router
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processAccessToken();
      if (mounted) {
        context.read<AuthProvider>().addListener(_onAuthStateChanged);
      }
    });
  }

  Future<void> _processAccessToken() async {
    try {
      // Check if Supabase returned an error
      if (widget.error != null) {
        if (mounted) {
          setState(() {
            hasValidToken = false;
            isExtractingToken = false;
          });
          _showResetLinkErrorDialog(title: 'Reset Link Error');
        }
        return;
      }

      final accessToken = widget.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        // Extract user ID from JWT using utility function
        final userId = extractUserIdFromJWT(accessToken);

        // Store temporarily for the password reset request (without 'Bearer ' prefix)
        // ApiClient will add the 'Bearer ' prefix when making the request
        await SecureStorage.write('accessToken', accessToken);
        if (userId != null) {
          await SecureStorage.write('userId', userId);
        }

        if (mounted) {
          setState(() {
            hasValidToken = true;
            isExtractingToken = false;
          });
        }
      } else {
        // No valid token found
        if (mounted) {
          setState(() {
            hasValidToken = false;
            isExtractingToken = false;
          });
          _showResetLinkErrorDialog(
            title: 'Invalid Link',
            customMessage:
                'This password reset link is invalid or has expired. '
                'Please request a new one.',
          );
        }
      }
    } catch (e) {
      // Handle token processing errors
      if (mounted) {
        setState(() {
          hasValidToken = false;
          isExtractingToken = false;
        });
        _showResetLinkErrorDialog(
          title: 'Invalid Link',
          customMessage:
              'This password reset link is invalid or has expired. '
              'Please request a new one.',
        );
      }
    }
  }

  void _showResetLinkErrorDialog({
    required String title,
    String? customMessage,
  }) {
    String errorMessage = customMessage ??
        (widget.errorDescription?.replaceAll('+', ' ') ??
        'The password reset link is invalid or has expired.');

    // Provide user-friendly messages for known error codes
    if (widget.errorCode == 'otp_expired') {
      errorMessage =
          'This password reset link has expired. Password reset links are '
          'valid for 1 hour. Please request a new one.';
    }

    AppDialog.showError(
      context: context,
      title: title,
      message: errorMessage,
      buttonText: 'Request New Link',
      barrierDismissible: false,
      onButtonPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.go('/profile/forgot-password');
      },
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    // Clean up listener if still active
    try {
      final authProvider = context.read<AuthProvider>();
      authProvider.removeListener(_onAuthStateChanged);
      authProvider.clearResetPasswordState();
    } catch (e) {
      // Listener already removed or context unavailable
    }
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.resetPasswordSuccess && !authProvider.isLoading) {
      // Remove listener first to prevent showing dialog multiple times
      authProvider.removeListener(_onAuthStateChanged);

      // Clear temporary auth data
      _clearTemporaryAuthData();

      // Show success dialog
      AppDialog.showSuccess(
        context: context,
        title: 'Password Reset',
        message: authProvider.resetPasswordMessage,
        buttonText: 'Sign In',
        barrierDismissible: false,
        onButtonPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.go('/profile/signin');
        },
      );
    }
  }

  Future<void> _clearTemporaryAuthData() async {
    try {
      await SecureStorage.delete('accessToken');
      await SecureStorage.delete('userId');
    } catch (e) {
      // Silently handle errors clearing temporary auth data
    }
  }

  void _validateForm() {
    final valid =
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading indicator while extracting token
    if (isExtractingToken) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Verifying reset link...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              Text(
                'Enter your new password below.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              if (authProvider.resetPasswordMessage.isNotEmpty &&
                  !authProvider.isLoading &&
                  !authProvider.resetPasswordSuccess)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.resetPasswordMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // New Password
              PasswordField(
                controller: passwordController,
                labelText: 'New Password',
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Confirm Password
              PasswordField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                textInputAction: TextInputAction.done,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onFieldSubmitted: () {
                  if (_formKey.currentState!.validate() && isFormValid) {
                    context.read<AuthProvider>().resetPassword(
                      passwordController.text,
                    );
                  }
                },
              ),

              OutlinedButton(
                onPressed:
                    (authProvider.isLoading || !hasValidToken || !isFormValid)
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            authProvider.resetPassword(passwordController.text);
                          }
                        },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor:
                      (hasValidToken && isFormValid)
                          ? Colors.white
                          : Colors.grey,
                  side: BorderSide(
                    color:
                        (hasValidToken && isFormValid)
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey,
                  ),
                  backgroundColor:
                      (hasValidToken && isFormValid)
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                ),
                child:
                    authProvider.isLoading
                        ? SizedBox(
                          width: 50,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
