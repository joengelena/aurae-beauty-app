import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
    return Center(
      child: SizedBox(
        width: 300,
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
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                ),
                backgroundColor:
                    isFormValid
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
              ),
              child: Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
