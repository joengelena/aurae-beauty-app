import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable decimal number form field for forms.
///
/// Only accepts decimal input with up to 2 decimal places and validates against min/max constraints.
/// Automatically removes optional fields from formData when empty.
class DecimalFormField<T extends FormDataProvider> extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final double min;
  final double max;
  final bool isRequired;
  final String? hintText;
  final String? prefixText;
  final IconData? prefixIcon;

  const DecimalFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.min = 0,
    this.max = double.infinity,
    this.isRequired = false,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
  });

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Required' : null;
    }

    final decimalValue = double.tryParse(value);

    if (decimalValue == null) {
      return 'Please enter a valid number';
    }

    if (decimalValue < min) {
      return 'Must be at least $min';
    }

    if (decimalValue > max) {
      return 'Must be at most $max';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final initialValue = provider.formData[fieldName]?.toString() ?? '';

    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
        hintText: hintText,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: _validator,
      onChanged: (value) {
        if (value.isEmpty && !isRequired) {
          provider.formData.remove(fieldName);
        } else {
          final decimalValue = double.tryParse(value);
          if (decimalValue != null) {
            provider.formData[fieldName] = decimalValue;
          }
        }
      },
    );
  }
}
