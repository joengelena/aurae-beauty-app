import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/presentation/widgets/common/app_dialog.dart';
import 'package:motorix_app/presentation/widgets/common/password_field.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:motorix_app/utils/utils.dart';
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

    if (authProvider.signUpSuccess && authProvider.signUpMessage.isNotEmpty) {
      final message = authProvider.signUpMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.clearSignUpState();
        AppDialog.showSuccess(
          context: context,
          title: 'Account Created',
          message: message,
          buttonText: 'OK',
          barrierDismissible: false,
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
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: themeRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.signInErrorMessage,
                            style: TextStyle(color: themeRed, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed:
                      authProvider.isLoading || !_isFormValid
                          ? null
                          : _handleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundColor: _isFormValid ? Colors.white : Colors.grey,
                    side: BorderSide(
                      color:
                          _isFormValid
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                    ),
                    backgroundColor:
                        _isFormValid
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.transparent,
                  ),
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
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
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
