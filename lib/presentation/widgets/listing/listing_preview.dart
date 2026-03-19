import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ListingPreview extends StatelessWidget {
  final double width;
  final Listing listing;

  const ListingPreview({super.key, required this.width, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isInWatchlist = listing.isInWatchlist ?? false;

    return GestureDetector(
      onTap: () {
        // Push current route onto stack for back button
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);

        context.go('/listings/${listing.id}');
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: width,
                    child: AspectRatio(
                      aspectRatio: AppConstants.listingImageAspectRatio,
                      child: Image.network(
                        listing.previewImgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final watchlistProvider =
                          context.read<WatchlistProvider>();
                      final listingsProvider = context.read<ListingsProvider>();

                      // Optimistically update UI
                      listingsProvider.toggleWatchlistStatus(
                        listing.id,
                        !isInWatchlist,
                      );

                      try {
                        if (isInWatchlist) {
                          await watchlistProvider.removeFromWatchlist(
                            listing.id,
                          );
                          if (context.mounted) {
                            FeedbackHelpers.showSuccessSnackBar(
                              context,
                              'Removed from watchlist',
                            );
                          }
                        } else {
                          await watchlistProvider.addToWatchlist(listing.id);
                          if (context.mounted) {
                            FeedbackHelpers.showSuccessSnackBar(
                              context,
                              'Added to watchlist',
                            );
                          }
                        }
                      } catch (e) {
                        // Revert on error
                        listingsProvider.toggleWatchlistStatus(
                          listing.id,
                          isInWatchlist,
                        );

                        if (context.mounted) {
                          FeedbackHelpers.showErrorSnackBar(
                            context,
                            'Failed to update watchlist',
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              '${listing.year} ${listing.make} ${listing.model}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Text(
                  listing.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.speed, size: 16),
                SizedBox(width: 4),
                Text(
                  listing.kilometers.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.local_gas_station, size: 16),
                SizedBox(width: 4),
                Text(
                  listing.fuelType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                if (listing.discountedPrice != null) ...[
                  Text(
                    formatPrice(listing.discountedPrice!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeRed,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    formatPrice(listing.originalPrice),
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ] else
                  Text(
                    formatPrice(listing.originalPrice),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
