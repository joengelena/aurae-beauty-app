import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class NumberFormField extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final int min;
  final int max;
  final bool isRequired;

  const NumberFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.min,
    required this.max,
    this.isRequired = false,
  });

  String? validator(String? value) {
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
    final provider = context.watch<PostListingProvider>();

    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: (value) => validator(value),
      onChanged: (val) {
        provider.postListingData[fieldName] = val;
      },
    );
  }
}
