import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shine_app/app_router.dart';
import 'package:shine_app/env_constants.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/logic/post_listing_provider.dart';
import 'package:shine_app/logic/profile_provider.dart';
import 'package:shine_app/logic/user_listings_provider.dart';
import 'package:shine_app/logic/listing_form_data_provider.dart';
import 'package:shine_app/logic/watchlist_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/logic/owner_profile_provider.dart';
import 'package:shine_app/logic/upcoming_bookings_provider.dart';
import 'package:shine_app/logic/week_schedule_provider.dart';
import 'package:shine_app/logic/business_settings_provider.dart';
import 'package:shine_app/data/cache_manager.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for caching (works on all platforms)
  await Hive.initFlutter();
  await CacheManager.instance.initialize();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Disable Provider type checking for interface types that are only accessed via context.read<>
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BackButtonProvider>(
          create: (_) => BackButtonProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(),
          update: (context, authProvider, profileProvider) {
            profileProvider!.updateAuthStatus(authProvider.isSignedIn);
            return profileProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserListingsProvider>(
          create: (_) => UserListingsProvider(),
          update: (context, authProvider, userListingsProvider) {
            userListingsProvider!.updateAuthStatus(authProvider.isSignedIn);
            return userListingsProvider;
          },
        ),
        ChangeNotifierProvider<FilteringProvider>(
          create: (_) => FilteringProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WatchlistProvider>(
          create: (_) => WatchlistProvider(),
          update: (context, authProvider, watchlistProvider) {
            watchlistProvider!.updateAuthStatus(authProvider.isSignedIn);
            return watchlistProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WardrobeProvider>(
          create: (_) => WardrobeProvider(),
          update: (context, authProvider, wardrobeProvider) {
            wardrobeProvider!.updateAuthStatus(authProvider.isSignedIn);
            return wardrobeProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DressDetailProvider>(
          create: (_) => DressDetailProvider(),
          update: (context, authProvider, dressDetailProvider) {
            dressDetailProvider!.updateAuthStatus(authProvider.isSignedIn);
            return dressDetailProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          ProfileProvider,
          ListingsProvider
        >(
          create: (_) => ListingsProvider(),
          update: (context, authProvider, profileProvider, listingsProvider) {
            listingsProvider!.updateAuthStatus(authProvider.isSignedIn);
            listingsProvider.updateUserLocation(
              profileProvider.currentUser?.location,
            );
            return listingsProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          ProfileProvider,
          PostListingProvider
        >(
          create: (_) => PostListingProvider(),
          update: (
            context,
            authProvider,
            profileProvider,
            postListingProvider,
          ) {
            postListingProvider!.updateAuthStatus(authProvider.isSignedIn);
            postListingProvider.setDefaultLocation(
              profileProvider.currentUser?.location,
            );
            return postListingProvider;
          },
        ),
        Provider<ListingFormDataProvider>(
          create: (context) => context.read<PostListingProvider>(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ListingDetailProvider>(
          create: (_) => ListingDetailProvider(),
          update: (context, authProvider, listingDetailProvider) {
            listingDetailProvider!.updateAuthStatus(authProvider.isSignedIn);
            return listingDetailProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WeekScheduleProvider>(
          create: (_) => WeekScheduleProvider(),
          update: (context, authProvider, weekScheduleProvider) {
            weekScheduleProvider!.updateAuthStatus(authProvider.isSignedIn);
            return weekScheduleProvider;
          },
        ),
        ChangeNotifierProvider<OwnerProfileProvider>(
          create: (_) => OwnerProfileProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UpcomingBookingsProvider>(
          create: (_) => UpcomingBookingsProvider(),
          update: (context, authProvider, upcomingBookingsProvider) {
            upcomingBookingsProvider!.updateAuthStatus(authProvider.isSignedIn);
            return upcomingBookingsProvider;
          },
        ),
        ChangeNotifierProvider<BusinessSettingsProvider>(
          create: (_) => BusinessSettingsProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = getAppRouter(auth);

    // Check auth silently on startup for refresh scenarios
    // This allows users who refresh to stay authenticated without going through splash
    _checkAuthSilently(auth);
  }

  /// Check authentication status if tokens exist (refresh scenario)
  /// If no tokens exist, user goes through splash page for full health + auth check
  Future<void> _checkAuthSilently(AuthProvider auth) async {
    final hasTokens = await auth.hasStoredTokens();

    if (hasTokens) {
      // User has tokens - likely a refresh, check auth in background
      // This allows staying on the current page without going through splash
      await auth.checkAuthStatus();
    }
    // If no tokens, user will be redirected to splash by router for full health + auth check
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: appTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
