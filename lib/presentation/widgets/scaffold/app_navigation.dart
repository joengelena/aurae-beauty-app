import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class AppNavigation extends StatelessWidget {
  final GoRouterState state;

  const AppNavigation({super.key, required this.state});

  int _calculateIndex(String uri) {
    if (uri.startsWith('/watchlist')) return 1;
    if (uri.startsWith('/post')) return 2;
    if (uri.startsWith('/garage')) return 3;
    return 0;
  }

  bool _isProfilePage(String uri) {
    return uri.startsWith('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final postListingProvider = context.watch<PostListingProvider>();
    final uri = state.uri.toString();
    final isProfilePage = _isProfilePage(uri);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 400,
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  indicatorColor: isProfilePage ? Colors.transparent : Colors.grey.shade400,
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return IconThemeData(
                      color: isSelected && !isProfilePage
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Colors.black,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 12,
                      color: isSelected && !isProfilePage
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.black,
                    );
                  }),
                ),
              ),
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
                      postListingProvider.resetProvider();
                      context.go('/post-listing');
                      break;
                    case 3:
                      context.go('/garage');
                      break;
                  }
                },
                selectedIndex: _calculateIndex(uri),
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
                    icon: Icon(Icons.home),
                    label: 'My Garage',
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
