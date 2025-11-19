import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/presentation/pages/edit_listing_page.dart';
import 'package:motorix_app/presentation/pages/post_listing_page.dart';
import 'package:motorix_app/presentation/pages/profile/change_password_page.dart';
import 'package:motorix_app/presentation/pages/profile/edit_profile_page.dart';
import 'package:motorix_app/presentation/pages/profile/email_verified_page.dart';
import 'package:motorix_app/presentation/pages/profile/forgot_password_page.dart';
import 'package:motorix_app/presentation/pages/listing_detail_page.dart';
import 'package:motorix_app/presentation/pages/listings_page.dart';
import 'package:motorix_app/presentation/pages/profile/profile_page.dart';
import 'package:motorix_app/presentation/pages/profile/reset_password_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_in_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_up_page.dart';
import 'package:motorix_app/presentation/pages/watchlist_page.dart';
import 'package:motorix_app/presentation/pages/garage_page.dart';
import 'package:motorix_app/presentation/widgets/scaffold/app_scaffold.dart';
import 'package:provider/provider.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter getAppRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/listings',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final signedIn = authProvider.isSignedIn;
      final path = state.uri.path;

      final pathIsAccessibleToSignedOutUser =
          path == '/profile/signin' ||
          path == '/profile/signup' ||
          path == '/profile/forgot-password' ||
          path == '/profile/reset-password';

      if (!signedIn && path == '/profile') return '/profile/signin';

      if (signedIn && pathIsAccessibleToSignedOutUser) return '/profile';

      return null;
    },
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
                  if (listingId == null) {
                    return NoTransitionPage(child: Text('Not Found'));
                  }

                  final listingDetailProvider =
                      context.read<ListingDetailProvider>();

                  listingDetailProvider.isLoading = true;

                  return NoTransitionPage(
                    child: ListingDetailPage(listingId: listingId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _shellNavigatorKey,
                    pageBuilder: (context, state) {
                      final listingId = state.pathParameters['listingId'];
                      if (listingId == null) {
                        return NoTransitionPage(child: Text('Not Found'));
                      }

                      return NoTransitionPage(
                        child: EditListingPage(listingId: listingId),
                      );
                    },
                  ),
                ],
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
            path: '/post-listing',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: PostListingPage()),
          ),
          GoRoute(
            path: '/garage',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: GaragePage()),
          ),
          GoRoute(
            path: '/profile',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: ProfilePage()),
            routes: [
              GoRoute(
                path: 'signup',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: SignUpPage());
                },
              ),
              GoRoute(
                path: 'signin',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: SignInPage());
                },
              ),
              GoRoute(
                path: 'forgot-password',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ForgotPasswordPage());
                },
              ),
              GoRoute(
                path: 'reset-password',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ResetPasswordPage());
                },
              ),
              GoRoute(
                path: 'email-verified',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: EmailVerifiedPage());
                },
              ),
              GoRoute(
                path: 'change-password',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ChangePasswordPage());
                },
              ),
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _shellNavigatorKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: EditProfilePage());
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
