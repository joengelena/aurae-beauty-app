import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

/// Returns true if signed in. Otherwise shows the auth sheet and returns false.
bool requireAuth(BuildContext context, {String? reason}) {
  final isSignedIn = context.read<AuthProvider>().isSignedIn;
  if (!isSignedIn) {
    _showAuthSheet(context, reason: reason);
    return false;
  }
  return true;
}

void _showAuthSheet(BuildContext context, {String? reason}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AuthPromptSheet(reason: reason),
  );
}

class _AuthPromptSheet extends StatelessWidget {
  final String? reason;
  const _AuthPromptSheet({this.reason});

  // A warm rose-brown for the dress icon — deeper than First Blush, not alarming.
  static const _iconColor = Color(0xFFC4706A);
  static const _iconBg = Color(0xFFF9E6E5);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(32, 16, 32, bottomPad + 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFEADFD8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Dress icon in soft blush ring
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _iconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checkroom_outlined,
              color: _iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),

          // Heading — fixed, warm, personal
          Text(
            'Looks like you\'re not signed in',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Context-specific body text
          Text(
            reason ?? 'Create a free account to browse dresses, save favourites, and make bookings.',
            style: textTheme.bodyMedium?.copyWith(color: themeTaupe, height: 1.55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/profile/signup');
              },
              child: const Text('Create a free account'),
            ),
          ),
          const SizedBox(height: 20),

          // Soft inline sign-in link — no competing button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already a member? ',
                style: textTheme.bodySmall?.copyWith(color: themeTaupe),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/profile/signin');
                },
                child: Text(
                  'Sign in',
                  style: textTheme.bodySmall?.copyWith(
                    color: themeText,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: themeText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
