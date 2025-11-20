import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddVehicleProvider>();

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
        CheckboxListTile(
          title: const Text('Set as primary vehicle'),
          subtitle: const Text('This will be your default vehicle'),
          value: provider.formData['isPrimary'] == 1,
          onChanged: (value) {
            provider.formData['isPrimary'] = value == true ? 1 : 0;
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
