import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class BasicVehicleInfo extends StatelessWidget {
  const BasicVehicleInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddVehicleProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        DropdownFormField<AddVehicleProvider>(
          labelText: 'Make',
          fieldName: 'make',
          options: provider.getAttributeValues('make'),
          isRequired: true,
        ),
        const StringFormField<AddVehicleProvider>(
          labelText: 'Model',
          fieldName: 'model',
          isRequired: true,
        ),
        NumberFormField<AddVehicleProvider>(
          labelText: 'Year',
          fieldName: 'year',
          isRequired: true,
          min: 1900,
          max: DateTime.now().year + 2,
        ),
      ],
    );
  }
}
