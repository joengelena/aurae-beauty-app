import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);

    // Listen for auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().addListener(_onAuthStateChanged);
      }
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    // Clean up listener if still active
    try {
      final authProvider = context.read<AuthProvider>();
      authProvider.removeListener(_onAuthStateChanged);
      authProvider.clearChangePasswordState();
    } catch (e) {
      // Listener already removed or context unavailable
    }
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.changePasswordSuccess && !authProvider.isLoading) {
      // Remove listener first to prevent showing dialog multiple times
      authProvider.removeListener(_onAuthStateChanged);

      // Show success dialog
      AppDialog.showSuccess(
        context: context,
        title: 'Password Changed',
        message: authProvider.changePasswordMessage,
        buttonText: 'OK',
        barrierDismissible: false,
        onButtonPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.go('/profile');
        },
      );
    }
  }

  void _validateForm() {
    final valid =
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmPasswordController.text &&
        newPasswordController.text.length >= 6;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Text(
                    'Enter your new password below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  if (authProvider.changePasswordMessage.isNotEmpty &&
                      !authProvider.isLoading &&
                      !authProvider.changePasswordSuccess)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        authProvider.changePasswordMessage,
                        style: TextStyle(color: themeRed, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // New Password using reusable widget
                  PasswordField(
                    controller: newPasswordController,
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

                  // Confirm Password using reusable widget
                  PasswordField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    textInputAction: TextInputAction.done,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (val != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onFieldSubmitted: () {
                      if (_formKey.currentState!.validate() && isFormValid) {
                        context.read<AuthProvider>().changePassword(
                          newPasswordController.text,
                        );
                      }
                    },
                  ),

                  ElevatedButton(
                    onPressed:
                        (authProvider.isLoading || !isFormValid)
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                authProvider.changePassword(
                                  newPasswordController.text,
                                );
                              }
                            },
                    child:
                        authProvider.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Change password'),
                  ),

                  TextButton(
                    onPressed: () => context.go('/profile'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
