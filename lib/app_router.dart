import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/presentation/pages/listings_page.dart';
import 'package:motorix_app/presentation/pages/profile_page.dart';
import 'package:motorix_app/presentation/pages/watchlist_page.dart';
import 'package:motorix_app/presentation/app_scaffold.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/listings',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, GoRouterState state, child) {
        return AppScaffold(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/listings',
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder:
              (context, state) => NoTransitionPage(child: ListingsPage()),
        ),
        GoRoute(
          path: '/watchlist',
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder:
              (context, state) => NoTransitionPage(child: WatchlistPage()),
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: _shellNavigatorKey,
          pageBuilder:
              (context, state) => NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
  ],
);
