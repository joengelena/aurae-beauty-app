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

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label, this.primary = false});

  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primary
            ? themeAccent.withValues(alpha: 0.3)
            : themePrimary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary ? themeAccent : themePrimary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: themeText),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
              color: themeText,
            ),
          ),
        ],
      ),
    );
  }
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

              // Rental price — typography only, no box
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatPrice(listing.pricePerDay),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeText,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '/ day',
                      style: TextStyle(fontSize: 14, color: themeTaupe),
                    ),
                  ],
                ),
              ),

              // Spec chips — size and condition are primary
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SpecChip(icon: Icons.straighten, label: listing.size, primary: true),
                    _SpecChip(icon: Icons.check_circle_outline, label: listing.condition, primary: true),
                    if (listing.color != null)
                      _SpecChip(icon: Icons.palette_outlined, label: listing.color!),
                    if (listing.dressType != null)
                      _SpecChip(icon: Icons.checkroom, label: listing.dressType!),
                  ],
                ),
              ),

              // Compact dress details
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  [
                    listing.brand,
                    listing.style,
                    if (listing.dressType != null) listing.dressType!,
                    if (listing.color != null) listing.color!,
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
              ),

              // TODO: Availability calendar goes here

              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description',
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

              // Owner contact
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contact Owner',
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
