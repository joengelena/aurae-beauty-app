import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatelessWidget {
  final GoRouterState state;

  const AppNavigation({super.key, required this.state});

  int _calculateIndex(String uri) {
    if (uri.startsWith('/watchlist')) return 1;
    if (uri.startsWith('/garage')) return 2;
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
                  height: 60,
                  indicatorColor: Colors.grey.shade400,
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return IconThemeData(
                      size: 24,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Colors.black,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.black,
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
                      context.go('/garage');
                      break;
                    case 3:
                      context.go('/profile');
                      break;
                  }
                },
                selectedIndex: _calculateIndex(uri),
                backgroundColor: Colors.white,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.search),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark),
                    label: 'Watchlist',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: 'My Garage',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
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
