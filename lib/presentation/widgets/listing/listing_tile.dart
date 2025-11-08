import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:intl/intl.dart';

class ListingTile extends StatelessWidget {
  static const double _imageSize = 105.0;
  static const double _borderRadius = 12.0;

  final Listing listing;
  final Widget? topRightButton;

  const ListingTile({super.key, required this.listing, this.topRightButton});

  String _formatEndDate(DateTime endDate) {
    return 'Ends ${DateFormat('d MMMM').format(endDate)}';
  }

  String _formatKilometers(int km) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(km)} km';
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return '\$${formatter.format(price)}';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: GestureDetector(
        onTap: () {
          context.go('/listings/${listing.id}');
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
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
                    child: Image.network(
                      listing.previewImgUrl,
                      width: _imageSize,
                      height: _imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: _imageSize,
                          height: _imageSize,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right side content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        spacing: 2,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${listing.year} ${listing.make} ${listing.model}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatKilometers(listing.kilometers),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.local_gas_station,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  listing.fuelType,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatEndDate(listing.endDate),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatPrice(listing.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  const Icon(Icons.remove_red_eye_outlined, size: 16),
                                  Text(
                                    listing.viewCount.toString(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (listing.status == 'sold')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SOLD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
