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
          ElevatedButton(
            onPressed: () {
              context.go('/profile/signin');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Sign In'),
          ),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              context.go('/profile/signup');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
