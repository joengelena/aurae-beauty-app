import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/app_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/listing_attributes_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/logic/profile_provider.dart';
import 'package:motorix_app/logic/user_listings_provider.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
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
        ChangeNotifierProvider<UserListingsProvider>(
          create: (_) => UserListingsProvider(),
        ),
        ChangeNotifierProvider<ListingAttributesProvider>(
          create: (_) => ListingAttributesProvider(),
        ),
        ChangeNotifierProvider<ListingsProvider>(
          create: (_) => ListingsProvider(),
        ),
        ChangeNotifierProvider<PostListingProvider>(
          create: (_) => PostListingProvider(),
        ),
        ChangeNotifierProvider<ListingDetailProvider>(
          create: (_) => ListingDetailProvider(),
        ),
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(),
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

    // Check if user is already authenticated (e.g., from previous session)
    // This must happen after the first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.checkAuthStatus();
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
