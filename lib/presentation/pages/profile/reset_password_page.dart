import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/presentation/widgets/common/app_dialog.dart';
import 'package:motorix_app/presentation/widgets/common/password_field.dart';
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// Conditional import for web-only JavaScript interop
import 'dart:js_interop' if (dart.library.js_interop) 'dart:js_interop';
import 'dart:js_interop_unsafe'
    if (dart.library.js_interop_unsafe) 'dart:js_interop_unsafe';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

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

    // Extract and store access token from URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractAndStoreAccessToken();
      if (mounted) {
        context.read<AuthProvider>().addListener(_onAuthStateChanged);
      }
    });
  }

  Future<void> _extractAndStoreAccessToken() async {
    try {
      String? accessToken;
      String? userId;

      if (kIsWeb) {
        // Extract from URL hash for web using JavaScript interop
        try {
          // Get the hash directly from JavaScript window.location
          final hash = _getLocationHash();

          if (kDebugMode) {
            final fullUrl = _getLocationHref();
            debugPrint('=== Password Reset Debug ===');
            debugPrint('Full URL: $fullUrl');
            debugPrint('Hash: $hash');
          }

          // Remove the first # character
          final cleanHash = hash.startsWith('#') ? hash.substring(1) : hash;

          // Flutter web uses hash routing, so the hash contains both:
          // #/profile/reset-password#access_token=...
          // We need to find the second # and extract everything after it
          final secondHashIndex = cleanHash.indexOf('#');

          if (secondHashIndex != -1) {
            // Extract the token parameters (everything after the second #)
            final tokenParams = cleanHash.substring(secondHashIndex + 1);

            if (kDebugMode) {
              debugPrint('Token params: $tokenParams');
            }

            final params = Uri.splitQueryString(tokenParams);
            accessToken = params['access_token'];

            if (kDebugMode) {
              debugPrint('Access token found: ${accessToken != null}');
            }

            if (accessToken != null) {
              userId = _extractUserIdFromJWT(accessToken);
              if (kDebugMode) {
                debugPrint('User ID extracted: ${userId != null}');
              }
            }
          }
        } catch (e, stackTrace) {
          debugPrint('Error extracting from URL: $e');
          if (kDebugMode) {
            debugPrint('Stack trace: $stackTrace');
          }
        }
      }

      if (accessToken != null) {
        // Store temporarily for the password reset request
        await SecureStorage.write('accessToken', 'Bearer $accessToken');
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
          _showInvalidLinkDialog();
        }

        if (kDebugMode) {
          debugPrint('No access token found');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error extracting access token: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }

      if (mounted) {
        setState(() {
          hasValidToken = false;
          isExtractingToken = false;
        });
        _showInvalidLinkDialog();
      }
    }
  }

  String? _extractUserIdFromJWT(String token) {
    try {
      // JWT is formatted as: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      String payload = parts[1];

      // Normalize base64 padding
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64.decode(payload));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      return payloadMap['sub'] as String?;
    } catch (e) {
      debugPrint('Error parsing JWT: $e');
      return null;
    }
  }

  // Helper methods for JavaScript interop (web only)
  String _getLocationHash() {
    if (!kIsWeb) return '';
    final window = globalContext;
    final location = window['location'] as JSObject;
    final hash = location['hash'];
    return (hash as JSString?)?.toDart ?? '';
  }

  String _getLocationHref() {
    if (!kIsWeb) return '';
    final window = globalContext;
    final location = window['location'] as JSObject;
    final href = location['href'];
    return (href as JSString?)?.toDart ?? '';
  }

  void _showInvalidLinkDialog() {
    AppDialog.showError(
      context: context,
      title: 'Invalid Link',
      message:
          'This password reset link is invalid or has expired. Please request a new one.',
      buttonText: 'OK',
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
      debugPrint('Error clearing temporary auth data: $e');
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
