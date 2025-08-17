import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreedToTermsAndConditions = false;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid =
        agreedToTermsAndConditions &&
        emailController.text.isNotEmpty &&
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
    return Center(
      child: SizedBox(
        width: 300,
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

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () => emailController.clear(),
                ),
              ),
            ),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () => passwordController.clear(),
                ),
              ),
            ),

            // Confirm Password
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () => confirmPasswordController.clear(),
                ),
              ),
            ),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: agreedToTermsAndConditions,
                  onChanged: (value) {
                    setState(() {
                      agreedToTermsAndConditions = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I agree to the Auto Mart Terms of Use and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            OutlinedButton(
              onPressed: isFormValid ? () {} : null,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: isFormValid ? Colors.white : Colors.grey,
                side: BorderSide(
                  color:
                      isFormValid
                          ? ColorScheme.of(context).secondary
                          : Colors.grey,
                ),
                backgroundColor:
                    isFormValid
                        ? ColorScheme.of(context).secondary
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
    );
  }
}
