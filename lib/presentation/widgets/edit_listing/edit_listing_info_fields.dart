import 'package:flutter/material.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class EditListingInfoFields extends StatelessWidget {
  const EditListingInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Listing Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        NumberFormField<EditListingProvider>(
          labelText: 'Price',
          fieldName: 'price',
          min: 0,
          max: 100000000,
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Vehicle Condition',
          fieldName: 'vehicleCondition',
          options: provider.getAttributeValues('vehicle_condition'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Location',
          fieldName: 'location',
          options: provider.getAttributeValues('location'),
          isRequired: true,
        ),
        DateFormField<EditListingProvider>(
          labelText: 'Listing End Date',
          fieldName: 'endDate',
          isRequired: true,
        ),
        StringFormField<EditListingProvider>(
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
