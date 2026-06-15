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

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.colorName);
  final String colorName;

  @override
  Widget build(BuildContext context) {
    final color = dressColorMap[colorName] ?? themeTaupe;
    final isLight = color.computeLuminance() > 0.85;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isLight
            ? Border.all(color: const Color(0xFFD0C8C0), width: 0.8)
            : null,
      ),
    );
  }
}

class ListingPreview extends StatelessWidget {
  final double width;
  final Listing listing;

  const ListingPreview({super.key, required this.width, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isInWatchlist = listing.isInWatchlist ?? false;

    return GestureDetector(
      onTap: () {
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);
        context.go('/listings/${listing.id}');
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay buttons
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: AppConstants.listingImageAspectRatio,
                    child: listing.previewImgUrl.isNotEmpty
                        ? Image.network(
                            listing.previewImgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),
                // Listing type badge (For Sale)
                if (listing.listingType == 'sell')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD0C8C0),
                          width: 0.75,
                        ),
                      ),
                      child: Text(
                        'For Sale',
                        style: TextStyle(
                          color: themeText,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                // Status badge (rented/sold)
                if (listing.status == 'sold' || listing.status == 'rented')
                  Positioned(
                    top: listing.listingType == 'sell' ? 36 : 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: listing.status == 'rented'
                            ? themeTaupe
                            : themeRose,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        listing.status == 'rented' ? 'Rented' : 'Sold',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Bookmark button
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      final watchlistProvider =
                          context.read<WatchlistProvider>();
                      final listingsProvider = context.read<ListingsProvider>();

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
                              'Removed from favorites',
                            );
                          }
                        } else {
                          await watchlistProvider.addToWatchlist(listing.id);
                          if (context.mounted) {
                            FeedbackHelpers.showSuccessSnackBar(
                              context,
                              'Saved to favorites',
                            );
                          }
                        }
                      } catch (e) {
                        listingsProvider.toggleWatchlistStatus(
                          listing.id,
                          isInWatchlist,
                        );
                        if (context.mounted) {
                          FeedbackHelpers.showErrorSnackBar(
                            context,
                            'Could not update favorites',
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWatchlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isInWatchlist ? themeRose : themeTaupe,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Text content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.style,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: themeText,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    listing.brand,
                    style: TextStyle(
                      fontSize: 11,
                      color: themeTaupe,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        'Size ${listing.size}',
                        style: TextStyle(fontSize: 11, color: themeTaupe),
                      ),
                      if (listing.color != null) ...[
                        const SizedBox(width: 8),
                        _ColorDot(listing.color!),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.color!,
                            style: TextStyle(fontSize: 11, color: themeTaupe),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        formatPrice(listing.pricePerDay),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: themeText,
                        ),
                      ),
                      if (listing.listingType != 'sell')
                        Text(
                          '/day',
                          style: TextStyle(
                            fontSize: 11,
                            color: themeTaupe,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5EFED),
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 32),
      ),
    );
  }
}
