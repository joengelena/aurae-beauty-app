import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/vehicle_dropdown_field.dart';

class VehicleDetailsSection extends StatelessWidget {
  const VehicleDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          'Vehicle Details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const StringFormField<AddVehicleProvider>(
          labelText: 'Color',
          fieldName: 'color',
        ),
        const VehicleDropdownField(
          labelText: 'Fuel Type',
          fieldName: 'fuelType',
          options: [
            'Petrol',
            'Diesel',
            'Electric',
            'Hybrid',
            'Plug-in Hybrid',
            'LPG',
            'CNG',
          ],
        ),
        const VehicleDropdownField(
          labelText: 'Transmission',
          fieldName: 'transmission',
          options: ['Automatic', 'Manual', 'CVT', 'Semi-Automatic'],
        ),
        const NumberFormField<AddVehicleProvider>(
          labelText: 'Odometer Reading',
          fieldName: 'odometerReading',
          min: 0,
          max: 9999999,
        ),
        const VehicleDropdownField(
          labelText: 'Odometer Unit',
          fieldName: 'odometerUnit',
          options: ['km', 'mi'],
        ),
      ],
    );
  }
}
