import 'package:flutter/material.dart';
import 'package:motorix_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

class DropdownFormField<T extends FormDataProvider>
    extends StatelessWidget {
  final String labelText;
  final bool isRequired;
  final String fieldName;
  final List<String> options;

  const DropdownFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.options,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final rawValue = provider.formData[fieldName];
    final currentValue = rawValue as String?;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      items:
          options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.formData[fieldName] = value;
        }
      },
      validator:
          isRequired
              ? (value) {
                if (value == null || value.isEmpty || value == 'None') {
                  return 'Required';
                }
                return null;
              }
              : null,
    );
  }
}
