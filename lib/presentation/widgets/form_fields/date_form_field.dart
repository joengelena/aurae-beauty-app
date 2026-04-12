import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

class DateFormField<T extends FormDataProvider> extends StatefulWidget {
  final String labelText;
  final String fieldName;
  final bool isRequired;

  /// The earliest date selectable in the picker. Defaults to today.
  final DateTime? firstDate;

  /// The latest date selectable in the picker. Defaults to year 2035.
  final DateTime? lastDate;

  const DateFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
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
    setState(() {});
  }

  void _clearField() {
    final provider = context.read<T>();
    _controller.clear();
    provider.formData.remove(widget.fieldName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final firstDate = widget.firstDate ?? DateTime.now();
    final lastDate = widget.lastDate ?? DateTime(2035);
    final hasValue = _controller.text.isNotEmpty;

    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText:
            widget.isRequired ? '${widget.labelText} *' : widget.labelText,
        suffixIcon:
            !widget.isRequired && hasValue
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearField,
                    ),
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                  ],
                )
                : const Icon(Icons.calendar_today),
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
          lastDate: lastDate,
        );

        if (picked != null) {
          _handleDateSelection(picked, provider);
        }
      },
    );
  }
}
