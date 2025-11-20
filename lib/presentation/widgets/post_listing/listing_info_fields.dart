import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class ListingInfoFields extends StatelessWidget {
  const ListingInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Listing Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        NumberFormField<PostListingProvider>(
          labelText: 'Price',
          fieldName: 'price',
          min: 0,
          max: 100000000,
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Vehicle Condition',
          fieldName: 'vehicleCondition',
          options: provider.getAttributeValues('vehicle_condition'),
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Location',
          fieldName: 'location',
          options: provider.getAttributeValues('location'),
          isRequired: true,
        ),
        DateFormField<PostListingProvider>(
          labelText: 'Listing End Date',
          fieldName: 'endDate',
          isRequired: true,
        ),
        StringFormField<PostListingProvider>(
          labelText: 'Description',
          fieldName: 'description',
          isRequired: true,
          maxLines: 5,
          alignLabelWithHint: true,
        ),
      ],
    );
  }
}
