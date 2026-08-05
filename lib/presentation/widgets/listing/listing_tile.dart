import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/size_utils.dart';
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
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            isLight
                ? Border.all(color: const Color(0xFFD0C8C0), width: 0.8)
                : null,
      ),
    );
  }
}

class ListingTile extends StatelessWidget {
  static const double _imageWidth = 140.0;
  static const double _borderRadius = 18.0;

  final Listing listing;
  final Widget? topRightButton;

  const ListingTile({super.key, required this.listing, this.topRightButton});

  String get _sizeLabel {
    if (listing.availableSizes.length <= 1) return 'Size ${listing.size}';
    final sorted = List<String>.from(listing.availableSizes)
      ..sort((a, b) => sizeRank(a).compareTo(sizeRank(b)));
    return 'Sizes ${sorted.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: GestureDetector(
        onTap: () {
          // Push current route onto stack for back button
          final currentRoute = GoRouterState.of(context).uri.path;
          context.read<BackButtonProvider>().pushRoute(currentRoute);

          context.go('/listings/${listing.id}');
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          elevation: 0.5,
          shadowColor: Colors.black.withValues(alpha:0.08),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            side: BorderSide(color: themePrimary.withValues(alpha:0.3), width: 0.5),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      bottomLeft: Radius.circular(_borderRadius),
                    ),
                    child: SizedBox(
                      width: _imageWidth,
                      child: AspectRatio(
                        aspectRatio: AppConstants.listingImageAspectRatio,
                        child: ColoredBox(
                          color: const Color(0xFFF5EFED),
                          child: CachedNetworkImage(
                            imageUrl: listing.previewImgUrl,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) {
                              return Container(
                                color: const Color(0xFFF5EFED),
                                child: Icon(
                                  Icons.broken_image,
                                  color: themeTaupe,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right side content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Column(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (listing.location.isNotEmpty)
                            Text(
                              listing.location,
                              style: TextStyle(
                                fontSize: 11,
                                color: themeTaupe,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            listing.name ?? listing.style,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: themeText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            listing.brand,
                            style: TextStyle(fontSize: 11, color: themeTaupe),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.straighten,
                                size: 14,
                                color: themeTaupe,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _sizeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeTaupe,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: themeTaupe,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  listing.condition,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeTaupe,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (listing.color != null)
                            Row(
                              children: [
                                _ColorDot(listing.color!),
                                const SizedBox(width: 6),
                              ],
                            ),
                          const SizedBox(height: 2),
                          Text(
                            listing.listingType == 'sell'
                                ? formatPrice(listing.pricePerDay)
                                : 'From ${formatPrice(listing.pricePerDay)}/day',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (listing.status == 'sold' || listing.status == 'rented')
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          listing.status == 'rented' ? themeTaupe : themeRose,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.status[0].toUpperCase() +
                          listing.status.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              if (topRightButton != null)
                Positioned(top: 3, right: 3, child: topRightButton!),
            ],
          ),
        ),
      ),
    );
  }
}
