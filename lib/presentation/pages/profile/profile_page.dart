import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: () {
            context.go('/profile/signup');
          },
          child: Text('Sign Up'),
        ),
        FilledButton(
          onPressed: () {
            context.go('/profile/signin');
          },
          child: Text('Sign In'),
        ),
        FilledButton(
          onPressed: () {
            context.go('/profile/forgot-password');
          },
          child: Text('Forgot Password'),
        ),
      ],
    );
  }
}
