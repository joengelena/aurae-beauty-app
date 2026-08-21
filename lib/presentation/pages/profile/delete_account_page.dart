import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/services/user_services.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final _userServices = UserServices();
  bool isFormValid = false;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid =
        passwordController.text.isNotEmpty &&
        passwordController.text.length >= 6;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (!_formKey.currentState!.validate()) return;

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmation();
    if (!confirmed || !mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await _userServices.deleteAccount(passwordController.text);

      if (!mounted) return;

      // Update auth state
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus();

      // Show success dialog
      if (!mounted) return;
      AppDialog.showSuccess(
        context: context,
        title: 'Account Deleted',
        message: 'Your account has been permanently deleted.',
        barrierDismissible: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        if (e is AppException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'Failed to delete account. Please try again.';
        }
      });
    }
  }

  Future<bool> _showFinalConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Final Confirmation'),
          content: const Text(
            'This action is permanent and cannot be undone. Are you absolutely sure you want to delete your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: themeRose),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 64, color: themeRose),

                  Text(
                    'Delete Account',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeRose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeRose.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This will permanently delete:',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: themeRose,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildWarningItem(
                          'Your profile and account information',
                        ),
                        _buildWarningItem('All your dress listings'),
                        _buildWarningItem('Your wardrobe and dress records'),
                        _buildWarningItem('Your watchlist'),
                        _buildWarningItem('All associated data'),
                        const SizedBox(height: 12),
                        Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                            color: themeRose,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (errorMessage.isNotEmpty && !isLoading)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeRose.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: themeRose, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: themeRose),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Text(
                          'Enter your password to confirm:',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: passwordController,
                          labelText: 'Password',
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onFieldSubmitted: () {
                            if (_formKey.currentState!.validate() &&
                                isFormValid) {
                              _handleDeleteAccount();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed:
                            isLoading ? null : () => context.go('/profile'),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed:
                            (isLoading || !isFormValid)
                                ? null
                                : _handleDeleteAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: themeRose,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: themeRose.withValues(alpha: 0.4),
                        ),
                        child:
                            isLoading
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
                                : const Text('Delete account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 16, color: themeRose),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: themeRose.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }
}
