import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/utils/theme.dart';

class SignInToAccess extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SignInToAccess({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: themeAccent),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => context.go('/profile/signin'),
                child: const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: () => context.go('/profile/signup'),
                child: const Text('Create an account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
