import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreedToTermsAndConditions = false;
  bool showCheckboxError = false;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    usernameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneNumberController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid =
        agreedToTermsAndConditions &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      child: Center(
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
                    'Sign Up',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                if (authProvider.signUpErrorMessage.isNotEmpty &&
                    !authProvider.isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      authProvider.signUpErrorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                TextFormField(
                  controller: firstNameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'First Name'),
                ),

                TextFormField(
                  controller: lastNameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),

                TextFormField(
                  controller: usernameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Username'),
                ),

                TextFormField(
                  controller: emailController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Email'),
                ),

                TextFormField(
                  controller: phoneNumberController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    // Add more phone validation if needed
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),

                TextFormField(
                  controller: passwordController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),

                TextFormField(
                  controller: confirmPasswordController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm password'),
                ),

                Row(
                  children: [
                    Checkbox(
                      value: agreedToTermsAndConditions,
                      onChanged: (value) {
                        setState(() {
                          agreedToTermsAndConditions = value!;
                          showCheckboxError = false;
                          _validateForm();
                        });
                      },
                      side:
                          showCheckboxError
                              ? BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 2,
                              )
                              : BorderSide(color: Colors.grey),
                    ),
                    Expanded(
                      child: Text(
                        'I agree to Motorix\'s Terms of Use and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                if (showCheckboxError)
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'You must agree to the Terms of Use and Privacy Policy.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),

                OutlinedButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate() &&
                                agreedToTermsAndConditions) {
                              authProvider.signUp(
                                firstNameController.text,
                                lastNameController.text,
                                usernameController.text,
                                emailController.text,
                                passwordController.text,
                                phoneNumberController.text,
                              );
                            } else if (!agreedToTermsAndConditions) {
                              setState(() {
                                showCheckboxError = true;
                              });
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
                            height: 20, // Adjust to match text height
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Text('Sign up'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/profile/signin');
                      },
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
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
