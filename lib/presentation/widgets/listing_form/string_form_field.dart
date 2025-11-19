import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable text form field for listing forms.
///
/// Supports both single-line and multi-line text input.
/// Automatically removes optional fields from formData when empty.
class StringFormField<T extends ListingFormDataProvider>
    extends StatelessWidget {
  /// The label text displayed in the field
  final String labelText;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// Maximum number of lines for the text field. Defaults to 1.
  final int maxLines;

  /// Whether to align the label with the hint text (useful for multiline fields)
  final bool alignLabelWithHint;

  const StringFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final initialValue = provider.formData[fieldName]?.toString() ?? '';

    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
        alignLabelWithHint: alignLabelWithHint,
      ),
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty) return 'Required';
                return null;
              }
              : null,
      onChanged: (val) {
        if (val.isEmpty && !isRequired) {
          // Remove optional field if empty
          provider.formData.remove(fieldName);
        } else {
          provider.formData[fieldName] = val;
        }
      },
    );
  }
}
