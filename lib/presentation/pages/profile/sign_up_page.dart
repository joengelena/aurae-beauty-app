import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
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

                TextFormField(
                  controller: firstNameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () => firstNameController.clear(),
                    ),
                  ),
                ),

                TextFormField(
                  controller: lastNameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () => lastNameController.clear(),
                    ),
                  ),
                ),

                TextFormField(
                  controller: usernameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () => usernameController.clear(),
                    ),
                  ),
                ),

                TextFormField(
                  controller: emailController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    // Add more email validation if needed
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
                  controller: phoneNumberController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    // Add more phone validation if needed
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () => phoneNumberController.clear(),
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
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () => confirmPasswordController.clear(),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Checkbox(
                      value: agreedToTermsAndConditions,
                      onChanged: (value) {
                        setState(() {
                          agreedToTermsAndConditions = value!;
                          _validateForm();
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I agree to Motorix\'s Terms of Use and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                OutlinedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.signUp(
                        firstNameController.text,
                        lastNameController.text,
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                        phoneNumberController.text,
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
                  child: Text('Sign up'),
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
