import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/string_form_field.dart';

class VehicleInfoFields extends StatelessWidget {
  const VehicleInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text('Vehicle Info', style: Theme.of(context).textTheme.headlineMedium),
        DropdownFormField(
          labelText: 'Make',
          fieldName: 'make',
          attributeName: 'make',
          isRequired: true,
        ),
        StringFormField(
          labelText: 'Model',
          fieldName: 'model',
          isRequired: true,
        ),
        NumberFormField(labelText: 'Year', fieldName: 'year', isRequired: true),
        NumberFormField(
          labelText: 'Kilometers',
          fieldName: 'kilometers',
          isRequired: true,
        ),
        DropdownFormField(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          attributeName: 'fuel_type',
          isRequired: true,
        ),
        DropdownFormField(
          labelText: 'Body Type',
          fieldName: 'bodyType',
          attributeName: 'body_type',
          isRequired: true,
        ),
        DropdownFormField(
          labelText: 'Drive Type',
          fieldName: 'driveType',
          attributeName: 'drive_type',
          isRequired: true,
        ),
      ],
    );
  }
}
