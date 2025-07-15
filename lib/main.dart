import 'package:flutter/material.dart';
import 'package:motorix_app/app_router.dart';
import 'package:motorix_app/logic/listing_filters_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ListingFiltersProvider>(
          create: (_) => ListingFiltersProvider(),
        ),
        ChangeNotifierProxyProvider<ListingFiltersProvider, ListingsProvider>(
          create: (_) => ListingsProvider(),
          update: (_, listingFiltersProvider, listingsProvider) {
            listingsProvider!.updateSelectedEqualFilters(
              listingFiltersProvider.selectedEqualFilters,
            );
            return listingsProvider;
          },
        ),
        ChangeNotifierProvider<PostListingProvider>(
          create: (_) => PostListingProvider(),
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
