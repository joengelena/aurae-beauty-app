import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFormField extends StatelessWidget {
  final TextEditingController fieldController;
  final String labelText;

  const NumberFormField({
    super.key,
    required this.fieldController,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: fieldController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: labelText),
    );
  }
}
