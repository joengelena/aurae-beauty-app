import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class VehicleInfoFields extends StatelessWidget {
  const VehicleInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Vehicle Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Make',
          fieldName: 'make',
          options: provider.getAttributeValues('make'),
          isRequired: true,
        ),
        StringFormField<PostListingProvider>(
          labelText: 'Model',
          fieldName: 'model',
          isRequired: true,
        ),
        NumberFormField<PostListingProvider>(
          labelText: 'Year',
          fieldName: 'year',
          min: 1900,
          max: DateTime.now().year + 1,
          isRequired: true,
        ),
        NumberFormField<PostListingProvider>(
          labelText: 'Kilometers',
          fieldName: 'kilometers',
          min: 0,
          max: 1000000,
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          options: provider.getAttributeValues('fuel_type'),
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Body Type',
          fieldName: 'bodyType',
          options: provider.getAttributeValues('body_type'),
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Drive Type',
          fieldName: 'driveType',
          options: provider.getAttributeValues('drive_type'),
          isRequired: true,
        ),
      ],
    );
  }
}
