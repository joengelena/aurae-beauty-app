import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/app_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/filtering_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/logic/profile_provider.dart';
import 'package:motorix_app/logic/user_listings_provider.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:motorix_app/logic/vehicle_detail_provider.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';
import 'package:motorix_app/data/services/vehicle_notification_service.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await VehicleNotificationService().initialize();

  // Disable Provider type checking for interface types that are only accessed via context.read<>
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
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
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GarageProvider>(
          create: (_) => GarageProvider(),
          update: (context, authProvider, garageProvider) {
            garageProvider!.updateAuthStatus(authProvider.isSignedIn);
            return garageProvider;
          },
        ),
        ChangeNotifierProxyProvider<WatchlistProvider, ListingsProvider>(
          create: (context) => ListingsProvider(),
          update: (context, watchlistProvider, listingsProvider) {
            return listingsProvider!;
          },
        ),
        ChangeNotifierProvider<PostListingProvider>(
          create: (_) => PostListingProvider(),
        ),
        Provider<ListingFormDataProvider>(
          create: (context) => context.read<PostListingProvider>(),
        ),
        ChangeNotifierProvider<ListingDetailProvider>(
          create: (_) => ListingDetailProvider(),
        ),
        ChangeNotifierProvider<VehicleDetailProvider>(
          create: (_) => VehicleDetailProvider(),
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

    // Set up notification tap handler
    VehicleNotificationService.onNotificationTap = (vehicleId) {
      _router.go('/garage/$vehicleId');
    };

    // Check if user is already authenticated (e.g., from previous session)
    // This must happen after the first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await auth.checkAuthStatus();

      // Fetch watchlist if user is signed in
      if (auth.isSignedIn && mounted) {
        context.read<WatchlistProvider>().fetchWatchlist();
      }
    });
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
