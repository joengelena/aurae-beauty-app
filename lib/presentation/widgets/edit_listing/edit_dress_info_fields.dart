import 'package:flutter/material.dart';
import 'package:shine_app/logic/edit_listing_provider.dart';
import 'package:shine_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class EditDressInfoFields extends StatelessWidget {
  const EditDressInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Dress Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Brand',
          fieldName: 'make',
          options: provider.getAttributeValues('make'),
          isRequired: true,
        ),
        StringFormField<EditListingProvider>(
          labelText: 'Style',
          fieldName: 'model',
          isRequired: true,
        ),
        NumberFormField<EditListingProvider>(
          labelText: 'Year',
          fieldName: 'year',
          min: 1900,
          max: 3000,
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Fabric Type',
          fieldName: 'fuelType',
          options: provider.getAttributeValues('fuel_type'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Dress Type',
          fieldName: 'bodyType',
          options: provider.getAttributeValues('body_type'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Fit Type',
          fieldName: 'driveType',
          options: provider.getAttributeValues('drive_type'),
          isRequired: true,
        ),
      ],
    );
  }
}
