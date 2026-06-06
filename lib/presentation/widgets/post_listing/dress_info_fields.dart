import 'package:flutter/material.dart';
import 'package:shine_app/logic/post_listing_provider.dart';
import 'package:shine_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class DressInfoFields extends StatelessWidget {
  const DressInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Dress Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Brand',
          fieldName: 'make',
          options: provider.getAttributeValues('make'),
          isRequired: true,
        ),
        StringFormField<PostListingProvider>(
          labelText: 'Style',
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
        DropdownFormField<PostListingProvider>(
          labelText: 'Fabric Type',
          fieldName: 'fuelType',
          options: provider.getAttributeValues('fuel_type'),
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Dress Type',
          fieldName: 'bodyType',
          options: provider.getAttributeValues('body_type'),
          isRequired: true,
        ),
        DropdownFormField<PostListingProvider>(
          labelText: 'Fit Type',
          fieldName: 'driveType',
          options: provider.getAttributeValues('drive_type'),
          isRequired: true,
        ),
      ],
    );
  }
}
