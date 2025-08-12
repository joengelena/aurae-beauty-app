import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/action_bar.dart';
import 'package:motorix_app/presentation/widgets/listing/contact_seller.dart';
import 'package:motorix_app/presentation/widgets/listing/image_carousel.dart';
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
    // Schedule after first frame so we’re not in the middle of a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingDetailProvider>().getListing(
        int.parse(widget.listingId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingDetailProvider>();
    final listing = provider.listing;
    final screenWidth = MediaQuery.of(context).size.width;

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
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            spacing: 16,
            children: [
              ImageCarousel(),

              ActionBar(
                onCall: () {},
                onEmail: () {},
                onToggleWatchlist: () {},
                isSaved: false,
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${listing.year} ${listing.make} ${listing.model}',
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
                          '\$${listing.price}',
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
                    width: screenWidth > 600 ? 300 : screenWidth * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        _DetailColumn(
                          label: 'Year',
                          value: listing.year.toString(),
                        ),
                        _DetailColumn(
                          label: 'Fuel type',
                          value: listing.fuelType,
                        ),
                        _DetailColumn(
                          label: 'Drive type',
                          value: listing.driveType,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        _DetailColumn(
                          label: 'Kilometers',
                          value: '${listing.kilometers}km',
                        ),
                        _DetailColumn(
                          label: 'Body style',
                          value: listing.bodyType,
                        ),
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
                    listing.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              ContactSeller(),
            ],
          ),
        ),
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
