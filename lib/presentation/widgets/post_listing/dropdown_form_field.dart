import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class DropdownFormField extends StatelessWidget {
  final String labelText;
  final bool isRequired;
  final String fieldName;
  final String attributeName;

  const DropdownFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.attributeName,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostListingProvider>();
    final listingAttributeOptions = provider.listingAttributeOptions;

    List<String> getAttributeValue() {
      for (ListingAttribute listingAttribute in listingAttributeOptions) {
        if (listingAttribute.name == attributeName) {
          return listingAttribute.attributeValues;
        }
      }
      return [];
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      items:
          getAttributeValue().map((val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
      onChanged: (val) {
        provider.postListingData[fieldName] = val as Object;
      },
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty) return 'Required';
                return null;
              }
              : null,
    );
  }
}
