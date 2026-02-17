import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/presentation/pages/edit_listing_page.dart';
import 'package:motorix_app/presentation/pages/post_listing_page.dart';
import 'package:motorix_app/presentation/pages/profile/change_password_page.dart';
import 'package:motorix_app/presentation/pages/profile/edit_profile_page.dart';
import 'package:motorix_app/presentation/pages/profile/email_verification_page.dart';
import 'package:motorix_app/presentation/pages/profile/forgot_password_page.dart';
import 'package:motorix_app/presentation/pages/listing_detail_page.dart';
import 'package:motorix_app/presentation/pages/listings_page.dart';
import 'package:motorix_app/presentation/pages/profile/profile_page.dart';
import 'package:motorix_app/presentation/pages/profile/reset_password_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_in_page.dart';
import 'package:motorix_app/presentation/pages/profile/sign_up_page.dart';
import 'package:motorix_app/presentation/pages/watchlist_page.dart';
import 'package:motorix_app/presentation/pages/garage_page.dart';
import 'package:motorix_app/presentation/pages/add_vehicle_page.dart';
import 'package:motorix_app/presentation/pages/edit_vehicle_page.dart';
import 'package:motorix_app/presentation/pages/add_service_page.dart';
import 'package:motorix_app/presentation/pages/vehicle_detail_page.dart';
import 'package:motorix_app/presentation/widgets/scaffold/app_scaffold.dart';
import 'package:provider/provider.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Auth pages that authenticated users should not access
const _authPages = [
  '/profile/signin',
  '/profile/signup',
  '/profile/forgot-password',
  '/profile/reset-password',
  '/profile/email-verification',
];

// Public pages accessible to unauthenticated users
const _publicPages = ['/listings', '/watchlist', '/garage'];

GoRouter getAppRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/profile/signin',
    refreshListenable: authProvider,
    errorBuilder: (context, state) {
      // Redirect to garage page for any routing errors (404s)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/garage');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
    redirect: (context, state) {
      final isSignedIn = authProvider.isSignedIn;
      final path = state.uri.path;

      // Handle Supabase email verification errors by redirecting to a dedicated page
      String? errorCode = Uri.splitQueryString(state.uri.path)['error_code'];
      if (errorCode != null && path != '/profile/email-verification') {
        return '/profile/email-verification?error_code=$errorCode';
      }

      final isAuthPage = _authPages.contains(path);
      final isPublicPage = _publicPages.contains(path);

      // Redirect unauthenticated users to sign-in (except for auth and public pages)
      if (!isSignedIn && !isAuthPage && !isPublicPage) {
        return '/profile/signin';
      }

      // Redirect authenticated users from auth pages to garage
      if (isSignedIn && isAuthPage) {
        return '/garage';
      }

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
                path: 'post',
                pageBuilder:
                    (context, state) =>
                        NoTransitionPage(child: PostListingPage()),
              ),
              GoRoute(
                path: ':listingId',
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
            path: '/garage',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: GaragePage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: AddVehiclePage());
                },
              ),
              GoRoute(
                path: ':vehicleId',
                pageBuilder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'];
                  if (vehicleId == null) {
                    return NoTransitionPage(child: Text('Not Found'));
                  }

                  return NoTransitionPage(
                    child: VehicleDetailPage(vehicleId: vehicleId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) {
                      final vehicleId = state.pathParameters['vehicleId']!;
                      return NoTransitionPage(
                        child: EditVehiclePage(vehicleId: vehicleId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add-service',
                    pageBuilder: (context, state) {
                      final vehicleId = int.parse(
                        state.pathParameters['vehicleId']!,
                      );
                      return NoTransitionPage(
                        child: AddServicePage(vehicleId: vehicleId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: ProfilePage()),
            routes: [
              GoRoute(
                path: 'signup',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: SignUpPage());
                },
              ),
              GoRoute(
                path: 'signin',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: SignInPage());
                },
              ),
              GoRoute(
                path: 'forgot-password',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ForgotPasswordPage());
                },
              ),
              GoRoute(
                path: 'reset-password',
                pageBuilder: (context, state) {
                  // Extract parameters from Supabase redirect URL
                  // Supabase sends: #access_token=...&expires_at=...&type=recovery
                  // GoRouter parses the URL, so fragment contains the parameters
                  final fragment = state.uri.fragment;
                  final params =
                      fragment.isNotEmpty
                          ? Uri.splitQueryString(fragment)
                          : <String, String>{};

                  return NoTransitionPage(
                    child: ResetPasswordPage(
                      accessToken: params['access_token'],
                      resetType: params['type'],
                      error: params['error'],
                      errorCode: params['error_code'],
                      errorDescription: params['error_description'],
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'email-verification',
                pageBuilder: (context, state) {
                  // error_code may arrive as a query param (forwarded by our
                  // redirect above) or in the fragment (direct Supabase redirect)
                  final errorCode =
                      Uri.splitQueryString(state.uri.path)['error_code'];

                  return NoTransitionPage(
                    child: EmailVerificationPage(errorCode: errorCode),
                  );
                },
              ),
              GoRoute(
                path: 'change-password',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ChangePasswordPage());
                },
              ),
              GoRoute(
                path: 'edit',
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
