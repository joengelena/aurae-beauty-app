import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_search_field.dart';
import 'package:provider/provider.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  static const _mainRoutes = [
    '/listings',
    '/watchlist',
    '/garage',
    '/profile',
    '/profile/signup',
    '/profile/signin',
  ];

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
    final isListingsPage = currentRoute == '/listings';

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
                  : const Text('Motorix'),
          centerTitle: !isListingsPage,
          scrolledUnderElevation: 0,
          actions: [
            if (isProfilePage)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
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
