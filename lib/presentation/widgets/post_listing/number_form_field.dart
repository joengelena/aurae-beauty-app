import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class NumberFormField extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final bool isRequired;

  const NumberFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: labelText),
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }

                final intVal = int.tryParse(val);
                if (intVal == null) {
                  return 'Must be a number';
                }

                return null;
              }
              : (val) {
                if (val != null && val.isNotEmpty) {
                  final year = int.tryParse(val);
                  if (year == null) {
                    return 'Must be a number';
                  }
                }

                return null;
              },
      onChanged: (val) {
        provider.postListingData[fieldName] = val;
      },
    );
  }
}
