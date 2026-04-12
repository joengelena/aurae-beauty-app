import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    // Listen for success state changes to show dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().addListener(_onAuthStateChanged);
      }
    });
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.forgotPasswordSuccess && !authProvider.isLoading) {
      // Remove listener first to prevent showing dialog multiple times
      authProvider.removeListener(_onAuthStateChanged);

      // Show success dialog
      AppDialog.showSuccess(
        context: context,
        title: 'Email Sent',
        message: authProvider.forgotPasswordMessage,
        buttonText: 'Back to Sign In',
        barrierDismissible: false,
        onButtonPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.go('/profile/signin');
        },
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    // Clean up listener if still active
    try {
      final authProvider = context.read<AuthProvider>();
      authProvider.removeListener(_onAuthStateChanged);
      authProvider.clearForgotPasswordState();
    } catch (e) {
      // Listener already removed or context unavailable
    }
    super.dispose();
  }

  void _validateForm() {
    final valid = emailController.text.isNotEmpty;
    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = context.watch<AuthProvider>();

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
                    'Forgot Password',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Text(
                    'Enter your email address and we will send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  if (authProvider.forgotPasswordMessage.isNotEmpty &&
                      !authProvider.isLoading &&
                      !authProvider.forgotPasswordSuccess)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        authProvider.forgotPasswordMessage,
                        style: TextStyle(color: themeRed, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Email
                  TextFormField(
                    controller: emailController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (!emailRegex.hasMatch(val))
                        return 'Enter a valid email';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () => emailController.clear(),
                      ),
                    ),
                  ),

                  OutlinedButton(
                    onPressed:
                        authProvider.isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                authProvider.forgotPassword(
                                  emailController.text,
                                );
                              }
                            },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      foregroundColor: isFormValid ? Colors.white : Colors.grey,
                      side: BorderSide(
                        color:
                            isFormValid
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey,
                      ),
                      backgroundColor:
                          isFormValid
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
                            : Text('Send email'),
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
