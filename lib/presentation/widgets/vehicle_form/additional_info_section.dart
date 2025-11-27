import 'package:flutter/material.dart';
import 'package:motorix_app/logic/vehicle_form_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleFormProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Additional Information',
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
        const StringFormField<VehicleFormProvider>(
          labelText: 'Vehicle Photo URL',
          fieldName: 'vehiclePhotoUrl',
        ),
        const StringFormField<VehicleFormProvider>(
          labelText: 'Notes',
          fieldName: 'notes',
          maxLines: 4,
          alignLabelWithHint: true,
        ),
      ],
    );
  }
}
