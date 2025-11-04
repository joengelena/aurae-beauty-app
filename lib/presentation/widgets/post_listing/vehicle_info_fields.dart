import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing_form/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/listing_form/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/listing_form/string_form_field.dart';

class VehicleInfoFields extends StatelessWidget {
  const VehicleInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          'Vehicle Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
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
        NumberFormField(
          labelText: 'Year',
          fieldName: 'year',
          min: 1900,
          max: DateTime.now().year + 1,
          isRequired: true,
        ),
        NumberFormField(
          labelText: 'Kilometers',
          fieldName: 'kilometers',
          min: 0,
          max: 1000000,
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
