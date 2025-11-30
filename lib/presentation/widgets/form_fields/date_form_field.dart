import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

class DateFormField<T extends FormDataProvider> extends StatefulWidget {
  final String labelText;
  final String fieldName;
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

class _DateFormFieldState<T extends FormDataProvider>
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

  DateTime _getInitialDateForPicker(DateTime firstDate) {
    if (_controller.text.isEmpty) {
      return DateTime.now();
    }

    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(_controller.text);
      return parsedDate.isBefore(firstDate) ? firstDate : parsedDate;
    } catch (e) {
      return DateTime.now();
    }
  }

  void _handleDateSelection(DateTime picked, FormDataProvider provider) {
    final formatted = DateFormat('yyyy-MM-dd').format(picked);
    _controller.text = formatted;
    provider.formData[widget.fieldName] = formatted;
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
        FocusScope.of(context).unfocus();

        final picked = await showDatePicker(
          context: context,
          initialDate: _getInitialDateForPicker(firstDate),
          firstDate: firstDate,
          lastDate: DateTime(2035),
        );

        if (picked != null) {
          _handleDateSelection(picked, provider);
        }
      },
    );
  }
}
