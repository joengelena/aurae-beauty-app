import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/presentation/widgets/listing_form/listing_form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable numeric form field for listing forms.
///
/// Only accepts integer input and validates against min/max constraints.
/// Automatically removes optional fields from formData when empty.
class NumberFormField extends StatelessWidget {
  /// The label text displayed in the field
  final String labelText;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// Minimum allowed value (inclusive)
  final int min;

  /// Maximum allowed value (inclusive)
  final int max;

  /// Whether this field is required for form validation
  final bool isRequired;

  const NumberFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.min,
    required this.max,
    this.isRequired = false,
  });

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Required' : null;
    }

    final intVal = int.tryParse(value);

    if (intVal == null) {
      return 'Must be a number';
    }

    if (intVal < min || intVal > max) {
      return 'Must be between $min and $max';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ListingFormDataProvider>();
    final initialValue = provider.formData[fieldName]?.toString() ?? '';

    return TextFormField(
      initialValue: initialValue,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      validator: _validator,
      onChanged: (val) {
        if (val.isEmpty && !isRequired) {
          // Remove the field if empty (for optional fields)
          provider.formData.remove(fieldName);
        } else {
          final intValue = int.tryParse(val);
          if (intValue != null) {
            provider.formData[fieldName] = intValue;
          }
          // Note: If parsing fails but field has content,
          // validator will catch it - don't store invalid data
        }
      },
    );
  }
}
