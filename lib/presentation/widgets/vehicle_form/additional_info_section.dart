import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          'Additional Information',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const StringFormField<AddVehicleProvider>(
          labelText: 'Vehicle Photo URL',
          fieldName: 'vehiclePhotoUrl',
        ),
        const StringFormField<AddVehicleProvider>(
          labelText: 'Notes',
          fieldName: 'notes',
          maxLines: 4,
          alignLabelWithHint: true,
        ),
      ],
    );
  }
}
