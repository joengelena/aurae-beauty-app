import 'package:flutter/material.dart';
import 'package:shine_app/logic/vehicle_form_provider.dart';
import 'package:shine_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class VehicleDetailsSection extends StatelessWidget {
  const VehicleDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleFormProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Vehicle Details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const StringFormField<VehicleFormProvider>(
          labelText: 'Color',
          fieldName: 'color',
        ),
        DropdownFormField<VehicleFormProvider>(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          options: provider.getAttributeValues('fuel_type'),
        ),
        DropdownFormField<VehicleFormProvider>(
          labelText: 'Transmission',
          fieldName: 'transmission',
          options: provider.getAttributeValues('transmission'),
        ),
        const NumberFormField<VehicleFormProvider>(
          labelText: 'Odometer Reading',
          fieldName: 'odometerReading',
          min: 0,
          max: 9999999,
        ),
        const DropdownFormField<VehicleFormProvider>(
          labelText: 'Odometer Unit',
          fieldName: 'odometerUnit',
          options: ['km', 'mi'],
        ),
      ],
    );
  }
}
