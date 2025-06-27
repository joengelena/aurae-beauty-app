import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  const TitleAppBar({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final showBack =
        ![
          '/listings',
          '/watchlist',
          '/profile',
          '/post-listing',
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
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // handle
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Log Out'),
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
