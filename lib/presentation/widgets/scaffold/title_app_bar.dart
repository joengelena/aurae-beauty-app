import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/presentation/widgets/listing/listing_search_field.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/business_settings_provider.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  static const _mainRoutes = [
    '/listings',
    '/watchlist',
    '/garage',
    '/wardrobe',
    '/profile',
    '/profile/signup',
    '/profile/signin',
  ];

  static String _titleForRoute(String? route) {
    if (route == null || route.isEmpty) return 'Aurae';
    if (route == '/wardrobe/add') return 'Add dress';
    if (route.startsWith('/wardrobe/') && route.endsWith('/edit')) return 'Edit dress';
    if (route.startsWith('/wardrobe/') && route.endsWith('/add-booking')) return 'Add booking';
    if (route.startsWith('/settings')) return 'Settings';
    if (route == '/profile/edit') return 'Edit profile';
    if (route == '/profile/change-password') return 'Change password';
    if (route.startsWith('/profile/')) return 'Account';
    if (route.startsWith('/owner/')) return 'Owner profile';
    return 'Aurae';
  }

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
    final authProvider = context.watch<AuthProvider>();
    final showBack = !_mainRoutes.contains(currentRoute);
    final isProfilePage = currentRoute == '/profile';
    final isWardrobePage = currentRoute == '/wardrobe';
    final isListingsPage = currentRoute == '/listings';
    final showSettingsIcon = (isProfilePage || isWardrobePage) && authProvider.isSignedIn;

    void onBack() {
      final backButtonProvider = context.read<BackButtonProvider>();

      // Try to pop from the route stack
      final previousRoute = backButtonProvider.popRoute();

      if (previousRoute != null && previousRoute.isNotEmpty) {
        // Navigate back to the route from stack
        context.go(previousRoute);
      } else if (context.canPop()) {
        context.pop();
      } else {
        // Fallback: navigate to parent route
        final currentRouteInSections = currentRoute!.split('/');
        currentRouteInSections.removeLast();
        final targetRoute = currentRouteInSections.join('/');
        context.go(targetRoute.isEmpty ? '/listings' : targetRoute);
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AppBar(
          leading: showBack ? BackButton(onPressed: () => onBack()) : null,
          title:
              isListingsPage
                  ? Consumer<ListingsProvider>(
                    builder: (context, listingsProvider, child) {
                      return ListingSearchField(
                        listingsProvider: listingsProvider,
                      );
                    },
                  )
                  : Text(_titleForRoute(currentRoute)),
          centerTitle: !isListingsPage,
          scrolledUnderElevation: 0,
          actions: [
            if (showSettingsIcon)
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Business settings',
                onPressed: () {
                  context.read<BusinessSettingsProvider>().load();
                  context.push('/settings');
                },
              ),
            if (isProfilePage)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                enabled: !authProvider.isLoading,
                onSelected: (value) {
                  if (value == 'Sign out') {
                    _showSignOutDialog(context, authProvider);
                  } else if (value == 'Delete account') {
                    context.push('/profile/delete-account');
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Delete account',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever, size: 20, color: themeRed),
                            const SizedBox(width: 12),
                            Text(
                              'Delete account',
                              style: TextStyle(color: themeRed),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
