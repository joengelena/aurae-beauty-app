import 'package:flutter/material.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/presentation/widgets/listing/contact_seller.dart';
import 'package:shine_app/presentation/widgets/listing/image_carousel.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key, required this.listingId});
  final String listingId;

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  @override
  void initState() {
    super.initState();
    // Schedule after first frame so we're not in the middle of a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingDetailProvider>().getListing(
        int.parse(widget.listingId),
      );
    });
  }

  String _formatListingAge(DateTime uploadDate) {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inDays == 0) {
      return 'Listed Today';
    } else if (difference.inDays == 1) {
      return 'Listed Yesterday';
    } else {
      return 'Listed ${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingDetailProvider>();
    final listing = provider.listing;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.listing == null || listing == null) {
      return Center(child: Text('Not Found'));
    }

    // Key specs for grid display
    final keySpecs = [
      {
        'icon': Icons.straighten,
        'label': 'Size',
        'value': listing.size,
      },
      {
        'icon': Icons.check_circle_outline,
        'label': 'Condition',
        'value': listing.condition,
      },
      if (listing.dressType != null)
        {
          'icon': Icons.checkroom,
          'label': 'Type',
          'value': listing.dressType!,
        },
      if (listing.color != null)
        {
          'icon': Icons.palette_outlined,
          'label': 'Color',
          'value': listing.color!,
        },
    ];

    // Dress details
    final dressDetails = {
      'Brand': listing.brand,
      'Style': listing.style,
      'Size': listing.size,
      'Condition': listing.condition,
      if (listing.dressType != null) 'Dress Type': listing.dressType,
      if (listing.color != null) 'Color': listing.color,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
          child: Column(
            spacing: 16,
            children: [
              ImageCarousel(imageUrls: listing.imageUrls),

              // Listing age and location
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      '${_formatListingAge(listing.uploadDate)} | ',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Icon(Icons.location_on, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      listing.location,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${listing.brand} — ${listing.style}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              // Rental price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rental price',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${formatPrice(listing.pricePerDay)}/day',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Key Specs Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 60,
                ),
                itemCount: keySpecs.length,
                itemBuilder: (context, index) {
                  final spec = keySpecs[index];
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          spec['icon'] as IconData,
                          size: 20,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                spec['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                spec['value'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Dress Details Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dress Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    for (var entry in dressDetails.entries)
                      if (entry.value != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),

              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Descritpion',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  listing.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Seller's contact information
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Seller Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ContactSeller(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
