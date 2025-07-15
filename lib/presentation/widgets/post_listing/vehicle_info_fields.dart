import 'package:flutter/material.dart';
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

        StringFormField(labelText: 'Make', fieldName: 'make', isRequired: true),
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
        StringFormField(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          isRequired: true,
        ),
        StringFormField(
          labelText: 'Body Type',
          fieldName: 'bodyType',
          isRequired: true,
        ),
        StringFormField(
          labelText: 'Drive Type',
          fieldName: 'driveType',
          isRequired: true,
        ),
      ],
    );
  }
}
