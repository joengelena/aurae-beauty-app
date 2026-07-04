import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatelessWidget {
  final GoRouterState state;

  const AppNavigation({super.key, required this.state});

  int _calculateIndex(String uri) {
    if (uri.startsWith('/watchlist')) return 1;
    if (uri.startsWith('/wardrobe')) return 2;
    if (uri.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final uri = state.uri.toString();

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
                      color: isSelected ? themeAccent : themeTaupe,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? themeAccent : themeTaupe,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                onDestinationSelected: (index) {
                  // Reset back button provider when navigating via navbar
                  context.read<BackButtonProvider>().reset();

                  switch (index) {
                    case 0:
                      context.go('/listings');
                      break;
                    case 1:
                      context.go('/watchlist');
                      break;
                    case 2:
                      context.go('/wardrobe');
                      break;
                    case 3:
                      context.go('/profile');
                      break;
                  }
                },
                selectedIndex: _calculateIndex(uri),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Browse',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon: Icon(Icons.favorite_rounded),
                    label: 'Favorites',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.checkroom_outlined),
                    selectedIcon: Icon(Icons.checkroom),
                    label: 'Wardrobe',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
