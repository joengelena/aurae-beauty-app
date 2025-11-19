import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable date picker form field for listing forms.
///
/// Displays a calendar picker and formats dates as yyyy-MM-dd.
/// Automatically removes optional fields from formData when empty.
class DateFormField<T extends ListingFormDataProvider> extends StatefulWidget {
  /// The label text displayed in the field
  final String labelText;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// The earliest date selectable in the picker. Defaults to today.
  final DateTime? firstDate;

  const DateFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
    this.firstDate,
  });

  @override
  State<DateFormField<T>> createState() => _DateFormFieldState<T>();
}

class _DateFormFieldState<T extends ListingFormDataProvider>
    extends State<DateFormField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final saved = context.read<T>().formData[widget.fieldName];
    _controller = TextEditingController(text: saved as String? ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final firstDate = widget.firstDate ?? DateTime.now();

    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText:
            widget.isRequired ? '${widget.labelText} *' : widget.labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
      ),
      validator:
          widget.isRequired
              ? (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              }
              : null,
      onTap: () async {
        // Remove focus so the keyboard doesn't flicker in
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
          provider.formData[widget.fieldName] = formatted;
        }
      },
    );
  }
}
