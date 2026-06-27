import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInToAccess extends StatelessWidget {
  final String message;

  const SignInToAccess({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () => context.go('/profile/signin'),
              child: const Text('Sign in'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: OutlinedButton(
              onPressed: () => context.go('/profile/signup'),
              child: const Text('Create an account'),
            ),
          ),
        ],
      ),
    );
  }
}
