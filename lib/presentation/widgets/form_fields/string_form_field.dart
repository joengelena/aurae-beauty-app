import 'package:flutter/material.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable text form field for forms.
///
/// Supports both single-line and multi-line text input.
/// Automatically removes optional fields from formData when empty.
class StringFormField<T extends FormDataProvider> extends StatefulWidget {
  /// The label text displayed in the field
  final String labelText;

  /// The key used to store this field's value in formData
  final String fieldName;

  /// Whether this field is required for form validation
  final bool isRequired;

  /// Maximum number of lines for the text field. Defaults to 1.
  final int maxLines;

  /// Whether to align the label with the hint text (useful for multiline fields)
  final bool alignLabelWithHint;

  const StringFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    this.isRequired = false,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  State<StringFormField<T>> createState() => _StringFormFieldState<T>();
}

class _StringFormFieldState<T extends FormDataProvider>
    extends State<StringFormField<T>> {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final hasValue = _controller.text.isNotEmpty;

    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText:
            widget.isRequired ? '${widget.labelText} *' : widget.labelText,
        border: const OutlineInputBorder(),
        alignLabelWithHint: widget.alignLabelWithHint,
        suffixIcon:
            !widget.isRequired && hasValue
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearField,
                )
                : null,
      ),
      validator:
          widget.isRequired
              ? (val) {
                if (val == null || val.isEmpty) return 'Required';
                return null;
              }
              : null,
      onChanged: (val) {
        if (val.isEmpty && !widget.isRequired) {
          provider.formData.remove(widget.fieldName);
        } else {
          provider.formData[widget.fieldName] = val;
        }
        setState(() {});
      },
    );
  }
}
