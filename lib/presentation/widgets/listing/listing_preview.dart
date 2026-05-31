import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/watchlist_provider.dart';
import 'package:shine_app/logic/listings_provider.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
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
              '${listing.brand} — ${listing.style}',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    listing.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.straighten, size: 16),
                SizedBox(width: 4),
                Text(
                  'Size ${listing.size}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              '${formatPrice(listing.pricePerDay)}/day',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
