import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/action_bar.dart';
import 'package:motorix_app/presentation/widgets/listing/contact_seller.dart';
import 'package:motorix_app/presentation/widgets/listing/image_carousel.dart';
import 'package:motorix_app/utils/utils.dart';
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

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.listing == null || listing == null) {
      return Center(child: Text('Not Found'));
    }

    final listingDetails = {
      'Make': listing.make,
      'Model': listing.model,
      'Year': listing.year,
      'Kilometers': listing.kilometers,
      'Fuel Type': listing.fuelType,
      'Body Type': listing.bodyType,
      'Drive Type': listing.driveType,
      'ORC Included': listing.orcIncluded,
      'Number Plate': listing.numberPlate,
      'Seats': listing.seats,
      'Doors': listing.doors,
      'Previous Owners': listing.previousOwners,
      'Color': listing.color,
      'Engine Size': listing.engineSize,
      'Transmission': listing.transmission,
      'Cylinders': listing.cylinders,
      'Rego Expiry Date':
          listing.regoExpiryDate != null
              ? formatDate(listing.regoExpiryDate!)
              : null,
      'WOF Expiry Date':
          listing.wofExpiryDate != null
              ? formatDate(listing.wofExpiryDate!)
              : null,
      'Location': listing.location,
      'Vehicle Condition': listing.vehicleCondition,
      'Upload Date': formatDate(listing.uploadDate),
      'End Date': formatDate(listing.endDate),
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            spacing: 16,
            children: [
              ImageCarousel(imageUrls: listing.imageUrls),

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

              for (var entry in listingDetails.entries)
                if (entry.value != null)
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        SizedBox(
                          width: 8.0,
                        ), // Adds a small space between label and value
                        Expanded(
                          child: Text(
                            '${entry.value}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
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
                    style: Theme.of(context).textTheme.bodyMedium,
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
