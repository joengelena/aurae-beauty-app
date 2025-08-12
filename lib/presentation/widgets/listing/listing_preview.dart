import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';

class ListingPreview extends StatelessWidget {
  final double width;
  final Listing listing;

  const ListingPreview({super.key, required this.width, required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/listings/${listing.id}');
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: width,
                height: width,
                child: Image.network(listing.previewImgUrl, fit: BoxFit.cover),
              ),
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
                Icon(Icons.attach_money, size: 16),
                Text(
                  listing.price.toString(),
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
