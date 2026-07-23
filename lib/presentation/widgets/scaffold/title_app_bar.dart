import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/cart_provider.dart';
import 'package:provider/provider.dart';

/// Uniform header shown on every screen: back arrow (sub-pages only),
/// the app name centered, and a profile shortcut on the right (hidden
/// on the Profile page itself, since that would just re-navigate there).
class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  // Bottom-nav destinations — no "back" concept, they're tabs, not a stack.
  static const _rootRoutes = [
    '/listings',
    '/watchlist',
    '/wardrobe',
    '/profile',
  ];

  // Auth screens: no back arrow (may be a forced redirect, not a real
  // "previous page") and no profile shortcut (would just redirect here
  // again while signed out).
  static const _authRoutes = ['/profile/signin', '/profile/signup'];

  const TitleAppBar({super.key, this.currentRoute});

  void _onBack(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final showBack =
        !_rootRoutes.contains(currentRoute) && !_authRoutes.contains(currentRoute);
    final showProfileIcon =
        currentRoute != '/profile' && !_authRoutes.contains(currentRoute);
    final showCartIcon =
        currentRoute != '/cart' && !_authRoutes.contains(currentRoute);
    final cartCount = context.watch<CartProvider>().itemCount;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AppBar(
          leading: showBack
              ? BackButton(onPressed: () => _onBack(context))
              : null,
          title: const Text('Aurae'),
          centerTitle: true,
          scrolledUnderElevation: 0,
          actions: [
            if (showCartIcon)
              IconButton(
                icon: Badge(
                  label: Text('$cartCount'),
                  isLabelVisible: cartCount > 0,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                tooltip: 'Cart',
                onPressed: () => context.go('/cart'),
              ),
            if (showProfileIcon)
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'Profile',
                onPressed: () => context.go('/profile'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
