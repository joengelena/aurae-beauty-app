import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/presentation/pages/profile/forgot_password_page.dart';
import 'package:motorix_app/presentation/pages/listing_detail_page.dart';
import 'package:motorix_app/presentation/pages/listings_page.dart';
import 'package:motorix_app/presentation/pages/profile/profile_page.dart';
import 'package:motorix_app/presentation/pages/profile/reset_password_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_in_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_up_page.dart';
import 'package:motorix_app/presentation/pages/watchlist_page.dart';
import 'package:motorix_app/presentation/widgets/scaffold/app_scaffold.dart';

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
          routes: [
            GoRoute(
              path: ':listingId',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                final listingId = state.pathParameters['listingId'];

                return NoTransitionPage(
                  child: ListingDetailPage(listingId: listingId ?? ''),
                );
              },
            ),
          ],
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
          routes: [
            GoRoute(
              path: '/signup',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return NoTransitionPage(child: SignUpPage());
              },
            ),
            GoRoute(
              path: '/signin',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return NoTransitionPage(child: SignInPage());
              },
            ),
            GoRoute(
              path: '/forgot-password',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return NoTransitionPage(child: ForgotPasswordPage());
              },
            ),
            GoRoute(
              path: '/reset-password',
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
                return NoTransitionPage(child: ResetPasswordPage());
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
