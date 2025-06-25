import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation extends StatelessWidget {
  final GoRouterState state;

  const AppNavigation({super.key, required this.state});

  int _calculateIndex(String uri) {
    if (uri.startsWith('/watchlist')) return 1;
    if (uri.startsWith('/post')) return 2;
    if (uri.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 400,
            child: NavigationBar(
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/listings');
                    break;
                  case 1:
                    context.go('/watchlist');
                    break;
                  case 2:
                    context.go('/post-listing');
                    break;
                  case 3:
                    context.go('/profile');
                    break;
                }
              },
              selectedIndex: _calculateIndex(state.uri.toString()),
              indicatorColor: Colors.grey.shade400,
              backgroundColor: Colors.white,
              height: 70,
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
                  icon: Icon(Icons.control_point_sharp),
                  label: 'Post',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
