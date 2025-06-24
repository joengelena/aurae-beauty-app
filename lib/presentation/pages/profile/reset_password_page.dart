import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
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
                'Reset Password',
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
                labelText: 'New Password',
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
              child: Text('Reset password'),
            ),
          ],
        ),
      ),
    );
  }
}
