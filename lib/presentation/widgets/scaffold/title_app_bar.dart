import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:provider/provider.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  const TitleAppBar({super.key, this.currentRoute});

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
    AuthProvider authProvider = context.watch<AuthProvider>();
    final showBack =
        ![
          '/listings',
          '/watchlist',
          '/profile',
          '/post-listing',
          '/profile/signup',
          '/profile/signin',
        ].contains(currentRoute);
    final showMenu = currentRoute == '/profile';

    void onBack() {
      final currentRouteInSections = currentRoute!.split('/');
      currentRouteInSections.removeLast();
      context.go(currentRouteInSections.join('/'));
    }

    return AppBar(
      leading: showBack ? BackButton(onPressed: () => onBack()) : null,
      title: Text('Motorix'),
      centerTitle: true,
      scrolledUnderElevation: 0,
      actions:
          showMenu
              ? [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  enabled: !authProvider.isLoading,
                  onSelected: (value) {
                    if (value == 'Sign out') {
                      _showSignOutDialog(context, authProvider);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'Sign out',
                          enabled: !authProvider.isLoading,
                          child: Row(
                            children: [
                              const Icon(Icons.logout, size: 20),
                              const SizedBox(width: 12),
                              const Text('Sign out'),
                              if (authProvider.isLoading) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                ),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
