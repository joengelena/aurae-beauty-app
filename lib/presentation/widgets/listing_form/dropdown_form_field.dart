import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/presentation/widgets/listing_form/listing_form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable dropdown form field for listing forms.
///
/// Displays options from listing attributes and validates selection.
/// Automatically removes optional fields from formData when empty.
class DropdownFormField extends StatelessWidget {
  /// The label text displayed in the field
  final String labelText;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// The attribute name to lookup in listingAttributeOptions
  final String attributeName;

  const DropdownFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.attributeName,
    this.isRequired = false,
  });

  /// Retrieves attribute values for the given attribute name
  List<String> _getAttributeValues(List<ListingAttribute> attributes) {
    try {
      return attributes
          .firstWhere((attr) => attr.name == attributeName)
          .attributeValues;
    } catch (e) {
      // Attribute not found - return empty list
      debugPrint('Warning: Attribute "$attributeName" not found in options');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ListingFormDataProvider>();
    final listingAttributeOptions = provider.listingAttributeOptions;
    final rawValue = provider.formData[fieldName];

    final items = _getAttributeValues(listingAttributeOptions);

    // Convert the initial value to string and validate it exists in items
    String? validatedValue;
    if (rawValue != null) {
      final stringValue = rawValue.toString();
      if (items.contains(stringValue)) {
        validatedValue = stringValue;
      }
    }

    return DropdownButtonFormField<String>(
      value: validatedValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
      onChanged: (val) {
        if (val != null) {
          provider.formData[fieldName] = val;
        }
      },
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty || val == 'None') {
                  return 'Required';
                }
                return null;
              }
              : null,
    );
  }
}
