import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class _NavDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AppNavigation extends StatelessWidget {
  final GoRouterState state;

  const AppNavigation({super.key, required this.state});

  static const _browse = _NavDestination(
    route: '/listings',
    icon: Icons.grid_view_rounded,
    selectedIcon: Icons.grid_view_rounded,
    label: 'Browse',
  );
  static const _favorites = _NavDestination(
    route: '/watchlist',
    icon: Icons.favorite_border_rounded,
    selectedIcon: Icons.favorite_rounded,
    label: 'Favorites',
  );
  // Only shown while browsing as the business (Owner/Staff) — a Customer
  // can only view and rent dresses, never list them, so there's nothing
  // for them to do on this tab.
  static const _wardrobe = _NavDestination(
    route: '/wardrobe',
    icon: Icons.checkroom_outlined,
    selectedIcon: Icons.checkroom,
    label: 'Wardrobe',
  );
  static const _profile = _NavDestination(
    route: '/profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  );

  int _calculateIndex(String uri, List<_NavDestination> destinations) {
    for (var i = 1; i < destinations.length; i++) {
      if (uri.startsWith(destinations[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final uri = state.uri.toString();
    final isBusinessActive = context.watch<ActiveProfileProvider>().isBusinessActive;

    final destinations = [
      _browse,
      _favorites,
      if (isBusinessActive) _wardrobe,
      _profile,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 600,
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  height: 64,
                  indicatorColor: themeAccent.withValues(alpha:0.3),
                  backgroundColor: themeBackground,
                  elevation: 0,
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return IconThemeData(
                      size: 26,
                      color: isSelected ? themeAccentInk : themeTaupe,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? themeAccentInk : themeTaupe,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                onDestinationSelected: (index) {
                  // Reset back button provider when navigating via navbar
                  context.read<BackButtonProvider>().reset();
                  context.go(destinations[index].route);
                },
                selectedIndex: _calculateIndex(uri, destinations),
                destinations: destinations
                    .map(
                      (d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
