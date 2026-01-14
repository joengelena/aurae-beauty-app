import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ListingsCarouselWidget extends StatefulWidget {
  const ListingsCarouselWidget({super.key});

  @override
  State<ListingsCarouselWidget> createState() => _ListingsCarouselWidgetState();
}

class _ListingsCarouselWidgetState extends State<ListingsCarouselWidget> {
  static const double _carouselHeight = 280.0;
  static const double _cardWidth = 200.0;

  @override
  void initState() {
    super.initState();
    // Fetch latest listings when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().fetchLatestListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use context.select to only rebuild when latestListings or isLoadingLatest changes
    final isLoading = context.select<ListingsProvider, bool>(
      (provider) => provider.isLoadingLatest,
    );
    final displayListings = context.select<ListingsProvider, List<Listing>>(
      (provider) => provider.latestListings,
    );

    // Show loading state when initially loading and no data
    if (isLoading && displayListings.isEmpty) {
      return _buildCarouselWrapper(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Show empty state if no listings available after loading
    if (!isLoading && displayListings.isEmpty) {
      return _buildCarouselWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No listings available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/listings'),
                child: const Text('Browse Listings'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCarouselWrapper(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayListings.length + 1, // +1 for "View More" card
          itemBuilder: (context, index) {
            // Last item is the "View More" card
            if (index == displayListings.length) {
              return _buildViewMoreCard(context);
            }

            final listing = displayListings[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildListingCard(context, listing),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarouselWrapper({required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Latest Listings',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: _carouselHeight, child: child),
      ],
    );
  }

  Widget _buildListingCard(BuildContext context, Listing listing) {
    return GestureDetector(
      onTap: () {
        // Store current route for back button
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);

        context.go('/listings/${listing.id}');
      },
      child: SizedBox(
        width: _cardWidth,
        child: Card(
          elevation: AppConstants.cardShadowElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  width: _cardWidth,
                  child: AspectRatio(
                    aspectRatio: AppConstants.listingImageAspectRatio,
                    child: Image.network(
                      listing.previewImgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${listing.year} ${listing.make} ${listing.model}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  listing.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatKilometers(listing.kilometers),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Price
                      if (listing.discountedPrice != null) ...[
                        Row(
                          children: [
                            Text(
                              formatPrice(listing.discountedPrice!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: themeRed,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatPrice(listing.originalPrice),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          formatPrice(listing.originalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewMoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/listings'),
      child: SizedBox(
        width: _cardWidth,
        child: Card(
          elevation: AppConstants.cardShadowElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View More',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse all listings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
