import 'package:flutter/material.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class EditVehicleInfoFields extends StatelessWidget {
  const EditVehicleInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Vehicle Information',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Make',
          fieldName: 'make',
          options: provider.getAttributeValues('make'),
          isRequired: true,
        ),
        StringFormField<EditListingProvider>(
          labelText: 'Model',
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
        NumberFormField<EditListingProvider>(
          labelText: 'Kilometers',
          fieldName: 'kilometers',
          min: 0,
          max: 9999999,
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          options: provider.getAttributeValues('fuel_type'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Body Type',
          fieldName: 'bodyType',
          options: provider.getAttributeValues('body_type'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Drive Type',
          fieldName: 'driveType',
          options: provider.getAttributeValues('drive_type'),
          isRequired: true,
        ),
      ],
    );
  }
}
