import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.signUpSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.clearSignUpState();
        AppDialog.showSuccess(
          context: context,
          title: 'You\'re all set',
          message: 'Your account is ready. Sign in below to get started.',
          buttonText: 'Got it',
          barrierDismissible: true,
        );
      });
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 24,
              children: [
                Center(
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (authProvider.signInErrorMessage.isNotEmpty &&
                    !authProvider.isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: themeRose.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeRose.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: themeRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.signInErrorMessage,
                                style: TextStyle(
                                  color: themeRed,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (authProvider.isEmailNotVerifiedError)
                        TextButton(
                          onPressed: authProvider.isResendingVerificationEmail
                              ? null
                              : () async {
                                  final email =
                                      _emailController.text.trim();
                                  await authProvider
                                      .resendVerificationEmail(email);
                                  if (context.mounted) {
                                    FeedbackHelpers.showSuccessSnackBar(
                                      context,
                                      'Verification email sent. Please check your inbox.',
                                    );
                                  }
                                },
                          child: authProvider.isResendingVerificationEmail
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Resend verification email'),
                        ),
                    ],
                  ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Email is required';
                    }
                    if (!emailRegex.hasMatch(val)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                  ),
                ),
                PasswordField(
                  controller: _passwordController,
                  labelText: 'Password',
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  onFieldSubmitted: () => _handleSignIn(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/profile/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: themeText,
                        decoration: TextDecoration.underline,
                        decorationColor: themeText,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      authProvider.isLoading || !_isFormValid
                          ? null
                          : _handleSignIn,
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
                          : const Text('Sign in'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile/signup'),
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: themeText,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: themeText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
