import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:provider/provider.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? currentRoute;

  const TitleAppBar({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = context.watch<AuthProvider>();
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
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'Sign out') {
                      await authProvider.signOut();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'Sign out',
                          child: Text('Sign out'),
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
