import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/business_settings_provider.dart';
import 'package:shine_app/presentation/widgets/profile/settings_row.dart';

/// Account-level actions for the signed-in user's own Profile page:
/// business settings, sign out, delete account. Previously these lived in
/// the app's top header; moved here so the header can stay a single
/// consistent back/title/profile bar across every screen.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await authProvider.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      children: [
        SettingsRow(
          icon: Icons.tune_rounded,
          label: 'Business settings',
          onTap: () {
            context.read<BusinessSettingsProvider>().load();
            context.push('/settings');
          },
        ),
        SettingsRow(
          icon: Icons.logout,
          label: 'Sign out',
          showChevron: false,
          onTap: () => _showSignOutDialog(context, authProvider),
        ),
        SettingsRow(
          icon: Icons.delete_forever,
          label: 'Delete account',
          showChevron: false,
          destructive: true,
          onTap: () => context.push('/profile/delete-account'),
        ),
      ],
    );
  }
}
