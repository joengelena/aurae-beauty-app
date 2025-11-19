import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:provider/provider.dart';

/// A reusable dropdown form field for vehicle forms.
class VehicleDropdownField extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final bool isRequired;
  final List<String> options;

  const VehicleDropdownField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.options,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AddVehicleProvider>();
    final currentValue = provider.formData[fieldName] as String?;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.formData[fieldName] = value;
        }
      },
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? 'Required' : null
          : null,
    );
  }
}
