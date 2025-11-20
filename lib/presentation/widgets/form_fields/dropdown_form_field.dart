import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable dropdown form field for listing forms.
///
/// Supports two modes:
/// 1. Attribute mode: Displays options from listing attributes (requires attributeName)
/// 2. Direct mode: Uses explicitly provided options (requires options parameter)
class DropdownFormField<T extends ListingFormDataProvider>
    extends StatelessWidget {
  /// The label text displayed in the field
  final String labelText;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// The attribute name to lookup in listingAttributeOptions (for attribute mode)
  final String? attributeName;

  /// Explicit list of options (for direct mode)
  final List<String>? options;

  const DropdownFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.attributeName,
    this.options,
    this.isRequired = false,
  }) : assert(
          attributeName != null || options != null,
          'Either attributeName or options must be provided',
        );

  /// Retrieves attribute values for the given attribute name
  List<String> _getAttributeValues(List<ListingAttribute> attributes) {
    if (attributeName == null) return [];
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
    final provider = context.read<T>();
    final rawValue = provider.formData[fieldName];

    // Get items from either explicit options or listing attributes
    final items = options ?? _getAttributeValues(provider.listingAttributeOptions);

    final currentValue = rawValue as String?;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.formData[fieldName] = value;
        }
      },
      validator: isRequired
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
