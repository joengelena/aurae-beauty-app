import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormField extends StatelessWidget {
  final TextEditingController dateController;
  final String labelText;
  final DateTime? firstDate;

  const DateFormField({
    super.key,
    required this.dateController,
    required this.labelText,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime effectiveFirstDate = firstDate ?? DateTime.now();

    return TextFormField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: effectiveFirstDate,
          lastDate: DateTime(2035),
        );

        if (pickedDate != null) {
          dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
    );
  }
}
