import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class DateFormField extends StatefulWidget {
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
  _DateFormFieldState createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final saved =
        context.read<PostListingProvider>().postListingData[widget.fieldName];
    _controller = TextEditingController(text: saved as String? ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostListingProvider>();
    final firstDate = widget.firstDate ?? DateTime.now();

    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      validator:
          widget.isRequired
              ? (val) {
                if (val == null || val.isEmpty) {
                  return '${widget.labelText} is required';
                }
                return null;
              }
              : null,
      onTap: () async {
        // Remove focus so the keyboard doesn’t flicker in
        FocusScope.of(context).unfocus();

        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: firstDate,
          lastDate: DateTime(2035),
        );

        if (picked != null) {
          final formatted = DateFormat('yyyy-MM-dd').format(picked);
          _controller.text = formatted;
          provider.postListingData[widget.fieldName] = formatted;
        }
      },
    );
  }
}
