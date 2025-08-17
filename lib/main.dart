import 'package:flutter/material.dart';
import 'package:motorix_app/app_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/listing_attributes_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ListingAttributesProvider>(
          create: (_) => ListingAttributesProvider(),
        ),
        ChangeNotifierProxyProvider<
          ListingAttributesProvider,
          ListingsProvider
        >(
          create: (_) => ListingsProvider(),
          update: (_, listingAttributesProvider, listingsProvider) {
            listingsProvider!.updateSelectedEqualFilters(
              listingAttributesProvider.selectedEqualFilters,
            );
            return listingsProvider;
          },
        ),
        ChangeNotifierProvider<PostListingProvider>(
          create: (_) => PostListingProvider(),
        ),
        ChangeNotifierProvider<ListingDetailProvider>(
          create: (_) => ListingDetailProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: getAppRouter(auth),
    );
  }
}
