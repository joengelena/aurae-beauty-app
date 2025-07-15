import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class DateFormField extends StatelessWidget {
  final String labelText;
  final String fieldName;
  final bool isRequired;
  final DateTime? firstDate;

  const DateFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();
    final DateTime effectiveFirstDate = firstDate ?? DateTime.now();

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      validator:
          isRequired
              ? (val) {
                if (val == null || val.isEmpty) return 'Required';
                return null;
              }
              : null,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: effectiveFirstDate,
          lastDate: DateTime(2035),
        );

        if (pickedDate != null) {
          provider.postListingData[fieldName] = DateFormat(
            'yyyy-MM-dd',
          ).format(pickedDate);
        }
      },
    );
  }
}
