import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class EmailVerificationExpired extends StatefulWidget {
  const EmailVerificationExpired({super.key});

  @override
  State<EmailVerificationExpired> createState() =>
      _EmailVerificationExpiredState();
}

class _EmailVerificationExpiredState extends State<EmailVerificationExpired> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResend(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    await authProvider.resendVerificationEmail(_emailController.text.trim());

    if (mounted) {
      FeedbackHelpers.showSuccessSnackBar(
        context,
        'Verification email sent. Please check your inbox.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: themePeach, width: 6),
                  ),
                  child: Center(
                    child: Icon(Icons.link_off, size: 64, color: themePeach),
                  ),
                ),

                Text(
                  'Link Expired',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                Text(
                  'Your verification link has expired. Enter your email below and we\'ll send you a new one.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                    return null;
                  },
                ),

                OutlinedButton(
                  onPressed:
                      authProvider.isResendingVerificationEmail
                          ? null
                          : () => _handleResend(authProvider),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child:
                      authProvider.isResendingVerificationEmail
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Resend verification email'),
                ),

                TextButton(
                  onPressed: () => context.go('/profile/signin'),
                  child: Text(
                    'Back to Sign In',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: themeLavender),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
