import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/contact_seller.dart';
import 'package:motorix_app/presentation/widgets/listing/image_carousel.dart';

class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({super.key, required String listingId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          ImageCarousel(),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '2022 Toyota Corolla WXB Hybrid Touring',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Asking price
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Asking price',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      '\$37,990',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '\$39,990',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Details',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          Row(
            children: [
              SizedBox(width: 16),
              SizedBox(
                width: screenWidth * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    _DetailColumn(label: 'Year', value: '2022'),
                    _DetailColumn(label: 'Fuel type', value: 'Hybrid'),
                    _DetailColumn(label: 'Drive type', value: '2WD'),
                  ],
                ),
              ),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    _DetailColumn(label: 'Kilometers', value: '23,480km'),
                    _DetailColumn(label: 'Body style', value: 'Station wagon'),
                    _DetailColumn(label: 'ORC Included', value: 'No'),
                  ],
                ),
              ),
            ],
          ),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Descritpion',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '''
                Experience the perfect blend of performance and style with the 2019 Thunderbolt VXR. Finished in an elegant midnight graphite, this 5-door hatchback turns heads wherever it goes. With only 48,000 km on the clock and a full-service history, this vehicle has been meticulously maintained.
                2.0L Turbocharged Petrol Engine\n
                8-Speed Automatic Transmission\n
                Apple CarPlay & Android Auto\n
                Leather Interior with Heated Seats\n
                Reverse Camera & Blind Spot Monitoring\n
                Keyless Entry and Push Start\n
                New Tyres (Installed 5,000km ago)\n
                Whether you're commuting, road-tripping, or simply enjoying the drive, the Thunderbolt VXR delivers a smooth, responsive ride and outstanding fuel efficiency.\n
                📍Located in Christchurch – viewing by appointment.\n
                💰 Asking price: \$23,500 (ONO)\n

                Contact now to arrange a test drive – don’t miss out on this reliable and stylish ride!''',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          ContactSeller(),
        ],
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DetailColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
