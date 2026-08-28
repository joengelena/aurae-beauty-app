import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/logic/profile_provider.dart';
import 'package:shine_app/presentation/pages/onboarding_page.dart';
import 'package:shine_app/presentation/pages/profile/add_business_profile_page.dart';
import 'package:shine_app/presentation/pages/profile/change_password_page.dart';
import 'package:shine_app/presentation/pages/profile/create_business_page.dart';
import 'package:shine_app/presentation/pages/profile/delete_account_page.dart';
import 'package:shine_app/presentation/pages/profile/edit_profile_page.dart';
import 'package:shine_app/presentation/pages/profile/my_bookings_page.dart';
import 'package:shine_app/presentation/pages/profile/invite_team_member_page.dart';
import 'package:shine_app/presentation/pages/profile/join_business_page.dart';
import 'package:shine_app/presentation/pages/profile/email_verification_page.dart';
import 'package:shine_app/presentation/pages/profile/forgot_password_page.dart';
import 'package:shine_app/presentation/pages/listing_detail_page.dart';
import 'package:shine_app/presentation/pages/listings_page.dart';
import 'package:shine_app/presentation/pages/profile/profile_page.dart';
import 'package:shine_app/presentation/pages/profile/reset_password_page.dart';
import 'package:shine_app/presentation/pages/profile/sign_in_page.dart';
import 'package:shine_app/presentation/pages/profile/sign_up_page.dart';
import 'package:shine_app/presentation/pages/splash_page.dart';
import 'package:shine_app/presentation/pages/watchlist_page.dart';
import 'package:shine_app/presentation/pages/cart_page.dart';
import 'package:shine_app/presentation/pages/wardrobe_dresses_page.dart';
import 'package:shine_app/presentation/pages/wardrobe_page.dart';
import 'package:shine_app/presentation/pages/add_dress_page.dart';
import 'package:shine_app/presentation/pages/edit_dress_page.dart';
import 'package:shine_app/presentation/pages/dress_detail_page.dart';
import 'package:shine_app/presentation/pages/add_booking_page.dart';
import 'package:shine_app/presentation/pages/add_damage_incident_page.dart';
import 'package:shine_app/presentation/pages/owner_profile_page.dart';
import 'package:shine_app/presentation/pages/business_settings_page.dart';
import 'package:shine_app/presentation/pages/privacy_policy_page.dart';
import 'package:shine_app/presentation/widgets/scaffold/app_scaffold.dart';
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
const _publicPages = ['/listings', '/watchlist', '/wardrobe', '/privacy'];

// Renter-only pages, and where to send someone who lands on one while the
// business profile is active — by deep link, or by switching profile while
// already sitting on the page. Hiding the entry points isn't enough on its
// own; without this you can still be looking at your cart as a boutique.
const _renterOnlyPages = <String, String>{
  '/cart': '/listings',
  '/profile/bookings': '/profile',
};

GoRouter getAppRouter(
  AuthProvider authProvider,
  ProfileProvider profileProvider,
  ActiveProfileProvider activeProfileProvider,
) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    // ActiveProfileProvider is in here so switching profiles re-runs the
    // redirect immediately, rather than only on the next navigation.
    refreshListenable: Listenable.merge([
      authProvider,
      profileProvider,
      activeProfileProvider,
    ]),
    errorBuilder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/listings');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
    redirect: (context, state) {
      final isSignedIn = authProvider.isSignedIn;
      final isAuthInitialized = authProvider.isAuthInitialized;
      final isLoading = authProvider.isLoading;
      final path = state.uri.path;

      // Allow splash page without any redirects
      if (path == '/splash') {
        return null;
      }

      // Handle Supabase email verification errors by redirecting to a dedicated page
      String? errorCode = Uri.splitQueryString(state.uri.path)['error_code'];
      if (errorCode != null && path != '/profile/email-verification') {
        return '/profile/email-verification?error_code=$errorCode';
      }

      final isAuthPage = _authPages.contains(path);
      final isPublicPage = _publicPages.contains(path) ||
          path.startsWith('/listings/') ||
          path.startsWith('/owner/');

      // If auth hasn't been initialized yet:
      // - If auth check is in progress (refresh scenario): stay on current page
      // - Otherwise (cold start): redirect to splash for health + auth check
      if (!isAuthInitialized && !isAuthPage && !isPublicPage) {
        if (isLoading) {
          // Auth check in progress - stay on current page while checking
          return null;
        }
        // Cold start - redirect to splash for full health + auth check
        return '/splash';
      }

      // Redirect unauthenticated users to sign-in (except for auth and public pages)
      if (!isSignedIn && !isAuthPage && !isPublicPage) {
        return '/profile/signin';
      }

      // Redirect authenticated users from auth pages to listings
      if (isSignedIn && isAuthPage) {
        return '/listings';
      }

      // Onboarding: show once until delivery option is set
      final profileReady = isSignedIn &&
          !profileProvider.isLoading &&
          profileProvider.currentUser != null;
      final needsOnboarding =
          profileReady && profileProvider.currentUser!.deliveryOption == null;

      if (needsOnboarding && path != '/onboarding') return '/onboarding';
      if (path == '/onboarding' && !needsOnboarding) {
        return isSignedIn ? '/listings' : '/profile/signin';
      }

      // Renter-only pages are unreachable while acting as the business.
      // Note this is UI scoping, not authorization — the same account can
      // switch to Customer and open these legitimately a second later.
      if (!activeProfileProvider.canActAsRenter) {
        final fallback = _renterOnlyPages[path];
        if (fallback != null) return fallback;
      }

      return null;
    },
    routes: [
      // Splash route - outside ShellRoute to hide bottom navigation
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(child: SplashPage()),
      ),
      // Onboarding route - outside ShellRoute (no nav bar)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingPage()),
      ),
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
            path: '/cart',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: CartPage()),
          ),
          GoRoute(
            path: '/wardrobe',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) => NoTransitionPage(child: WardrobePage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder:
                    (context, state) => NoTransitionPage(child: AddDressPage()),
              ),
              // Must stay above ':dressId' — go_router matches in declaration
              // order, so a dynamic segment declared first would swallow this
              // and try to open a dress with the id "dresses".
              GoRoute(
                path: 'dresses',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: WardrobeDressesPage()),
              ),
              GoRoute(
                path: ':dressId',
                pageBuilder: (context, state) {
                  final dressId = state.pathParameters['dressId']!;
                  return NoTransitionPage(
                    child: DressDetailPage(dressId: dressId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) {
                      final dressId = state.pathParameters['dressId']!;
                      return NoTransitionPage(
                        child: EditDressPage(dressId: dressId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add-booking',
                    pageBuilder: (context, state) {
                      final dressId = int.parse(
                        state.pathParameters['dressId']!,
                      );
                      return NoTransitionPage(
                        child: AddBookingPage(dressId: dressId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add-damage-incident',
                    pageBuilder: (context, state) {
                      final dressId = int.parse(
                        state.pathParameters['dressId']!,
                      );
                      return NoTransitionPage(
                        child: AddDamageIncidentPage(dressId: dressId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'damage-incidents/:incidentId',
                    pageBuilder: (context, state) {
                      final dressId = int.parse(
                        state.pathParameters['dressId']!,
                      );
                      final incidentId = int.parse(
                        state.pathParameters['incidentId']!,
                      );
                      return NoTransitionPage(
                        child: AddDamageIncidentPage(
                          dressId: dressId,
                          incidentId: incidentId,
                        ),
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
              GoRoute(
                path: 'bookings',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: MyBookingsPage());
                },
              ),
              GoRoute(
                path: 'delete-account',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: DeleteAccountPage());
                },
              ),
              GoRoute(
                path: 'add-business',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: AddBusinessProfilePage());
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    pageBuilder: (context, state) {
                      return NoTransitionPage(child: CreateBusinessPage());
                    },
                  ),
                  GoRoute(
                    path: 'join',
                    pageBuilder: (context, state) {
                      return NoTransitionPage(child: JoinBusinessPage());
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'invite',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: InviteTeamMemberPage());
                },
              ),
            ],
          ),
          GoRoute(
            path: '/owner/:userId',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return NoTransitionPage(child: OwnerProfilePage(userId: userId));
            },
          ),
          GoRoute(
            path: '/settings',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessSettingsPage()),
          ),
          GoRoute(
            path: '/privacy',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: PrivacyPolicyPage()),
          ),
        ],
      ),
    ],
  );
}
