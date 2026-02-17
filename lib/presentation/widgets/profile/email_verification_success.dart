import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/utils/theme.dart';

class EmailVerificationSuccess extends StatelessWidget {
  const EmailVerificationSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: themeGreen, width: 6),
            ),
            child: Center(
              child: Icon(Icons.check, size: 64, color: themeGreen),
            ),
          ),

          Text(
            'Email Verified!',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your email has been successfully verified. You can now sign in to your account.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          OutlinedButton(
            onPressed: () => context.go('/profile/signin'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              foregroundColor: Colors.white,
              side: BorderSide(color: Theme.of(context).colorScheme.secondary),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Continue to Sign In'),
          ),
        ],
      ),
    );
  }
}
