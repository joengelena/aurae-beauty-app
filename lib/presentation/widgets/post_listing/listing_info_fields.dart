import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/date_form_field.dart';
import 'package:provider/provider.dart';

class ListingInfoFields extends StatelessWidget {
  const ListingInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      children: [
        Text('Listing Info', style: Theme.of(context).textTheme.headlineMedium),
        TextFormField(
          controller: provider.locationController,
          decoration: InputDecoration(labelText: 'Location'),
        ),
        TextFormField(
          controller: provider.conditionController,
          decoration: InputDecoration(labelText: 'Vehicle Condition'),
        ),
        TextFormField(
          controller: provider.priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Price'),
        ),
        DateFormField(
          dateController: provider.listingEndDateController,
          labelText: 'Listing End Date',
        ),
        TextFormField(
          controller: provider.descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
          maxLines: 4,
        ),
      ],
    );
  }
}
