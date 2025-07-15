import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class StringFormField extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final bool isRequired;

  const StringFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty) return 'Required';
                return null;
              }
              : null,
      onSaved: (val) {
        if (val != null && val.isNotEmpty) {
          provider.postListingData[fieldName] = val;
        }
      },
    );
  }
}
