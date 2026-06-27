import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
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
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreedToTermsAndConditions = false;
  bool showCheckboxError = false;
  bool isFormValid = false;
  List<String> locationOptions = [];
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneNumberController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    _loadLocationOptions();
  }

  void _loadLocationOptions() {
    setState(() {
      locationOptions = const [
        'Auckland', 'Wellington', 'Christchurch', 'Hamilton', 'Tauranga',
        'Napier-Hastings', 'Dunedin', 'Palmerston North', 'Nelson', 'Rotorua',
        'New Plymouth', 'Whangarei', 'Invercargill', 'Whanganui', 'Gisborne',
      ];
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
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
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        selectedLocation != null;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = context.watch<AuthProvider>();

    if (authProvider.signUpSuccess && authProvider.signUpMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/profile/signin');
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
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
                      style: TextStyle(color: themeRed, fontSize: 14),
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

                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  decoration: InputDecoration(labelText: 'Location'),
                  items:
                      locationOptions.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                      _validateForm();
                    });
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                ),

                PasswordField(
                  controller: passwordController,
                  labelText: 'Password',
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                PasswordField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm password',
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
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
                        'I agree to Aurae\'s Terms of Use and Privacy Policy',
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

                ElevatedButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate() &&
                                agreedToTermsAndConditions &&
                                selectedLocation != null) {
                              authProvider.signUp(
                                firstNameController.text,
                                lastNameController.text,
                                emailController.text,
                                passwordController.text,
                                phoneNumberController.text,
                                selectedLocation!,
                              );
                            } else if (!agreedToTermsAndConditions) {
                              setState(() {
                                showCheckboxError = true;
                              });
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
                          : const Text('Sign up'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile/signin'),
                      child: Text(
                        'Sign in',
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
