import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.dispose();
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
    return Center(
      child: SizedBox(
        width: 300,
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
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
