import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable numeric form field for forms.
///
/// Only accepts integer input and validates against min/max constraints.
/// Automatically removes optional fields from formData when empty.
class NumberFormField<T extends FormDataProvider> extends StatefulWidget {
  /// The label text displayed in the field
  final String labelText;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// Minimum allowed value (inclusive)
  final int min;

  /// Maximum allowed value (inclusive)
  final int max;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// Whether this field is read-only
  final bool isReadOnly;

  const NumberFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.min,
    required this.max,
    this.isRequired = false,
    this.isReadOnly = false,
  });

  @override
  State<NumberFormField<T>> createState() => _NumberFormFieldState<T>();
}

class _NumberFormFieldState<T extends FormDataProvider>
    extends State<NumberFormField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<T>();
    final initialValue = provider.formData[widget.fieldName]?.toString() ?? '';
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearField() {
    final provider = context.read<T>();
    _controller.clear();
    provider.formData.remove(widget.fieldName);
    setState(() {});
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return widget.isRequired ? 'Required' : null;
    }

    final intVal = int.tryParse(value);

    if (intVal == null) {
      return 'Must be a number';
    }

    if (intVal < widget.min || intVal > widget.max) {
      return 'Must be between ${widget.min} and ${widget.max}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final hasValue = _controller.text.isNotEmpty;

    return TextFormField(
      controller: _controller,
      readOnly: widget.isReadOnly,
      enabled: !widget.isReadOnly,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            widget.isRequired ? '${widget.labelText} *' : widget.labelText,
        border: const OutlineInputBorder(),
        suffixIcon:
            !widget.isRequired && hasValue && !widget.isReadOnly
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearField,
                )
                : null,
      ),
      validator: _validator,
      onChanged: (val) {
        if (val.isEmpty && !widget.isRequired) {
          provider.formData.remove(widget.fieldName);
        } else {
          final intValue = int.tryParse(val);
          if (intValue != null) {
            provider.formData[widget.fieldName] = intValue;
          }
        }
        setState(() {});
      },
    );
  }
}
