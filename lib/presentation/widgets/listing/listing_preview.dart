import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/utils/constants.dart';
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
        context.push('/listings/${listing.id}');
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
                      child: Image.network(listing.previewImgUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final authProvider = context.read<AuthProvider>();

                      // Check if user is signed in
                      if (!authProvider.isSignedIn) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please sign in or sign up to add listings to your watchlist'),
                              action: SnackBarAction(
                                label: 'Sign In',
                                onPressed: () {
                                  context.go('/profile/signin');
                                },
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      final watchlistProvider = context.read<WatchlistProvider>();
                      final listingsProvider = context.read<ListingsProvider>();

                      // Optimistically update UI
                      listingsProvider.toggleWatchlistStatus(listing.id, !isInWatchlist);

                      try {
                        if (isInWatchlist) {
                          await watchlistProvider.removeFromWatchlist(listing.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed from watchlist')),
                            );
                          }
                        } else {
                          await watchlistProvider.addToWatchlist(listing.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to watchlist')),
                            );
                          }
                        }
                      } catch (e) {
                        // Revert on error
                        listingsProvider.toggleWatchlistStatus(listing.id, isInWatchlist);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update watchlist'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWatchlist
                            ? Icons.bookmark
                            : Icons.bookmark_border,
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
                      color: Colors.red,
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
