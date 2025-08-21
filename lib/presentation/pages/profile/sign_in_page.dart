import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
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
      child: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.signInErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextFormField(
                controller: emailController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
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

              TextFormField(
                controller: passwordController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    onPressed: () => passwordController.clear(),
                  ),
                ),
              ),

              OutlinedButton(
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            authProvider.signIn(
                              emailController.text,
                              passwordController.text,
                            );
                          }
                        },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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
                          height: 20, // Adjust to match text height
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : Text('Sign in'),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/profile/signup');
                    },
                    child: Text(
                      'Sign up',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
