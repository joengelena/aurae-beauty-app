import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing_form/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/listing_form/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/listing_form/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/listing_form/string_form_field.dart';

class ListingInfoFields extends StatelessWidget {
  const ListingInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          'Listing Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        NumberFormField(
          labelText: 'Price',
          fieldName: 'price',
          min: 0,
          max: 100000000,
          isRequired: true,
        ),
        DropdownFormField(
          labelText: 'Vehicle Condition',
          fieldName: 'vehicleCondition',
          attributeName: 'vehicle_condition',
          isRequired: true,
        ),
        DropdownFormField(
          labelText: 'Location',
          fieldName: 'location',
          attributeName: 'location',
          isRequired: true,
        ),
        DateFormField(
          labelText: 'Listing End Date',
          fieldName: 'endDate',
          isRequired: true,
        ),
        StringFormField(
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
