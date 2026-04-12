import 'package:flutter/material.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

class DropdownFormField<T extends FormDataProvider> extends StatefulWidget {
  final String labelText;
  final bool isRequired;
  final String fieldName;
  final List<String> options;

  const DropdownFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.options,
    this.isRequired = false,
  });

  @override
  State<DropdownFormField<T>> createState() => _DropdownFormFieldState<T>();
}

class _DropdownFormFieldState<T extends FormDataProvider>
    extends State<DropdownFormField<T>> {
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    final provider = context.read<T>();
    final rawValue = provider.formData[widget.fieldName];
    _currentValue = rawValue as String?;
  }

  void _clearField() {
    final provider = context.read<T>();
    provider.formData.remove(widget.fieldName);
    setState(() {
      _currentValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final hasValue = _currentValue != null && _currentValue != 'None';

    return DropdownButtonFormField<String>(
      value: _currentValue,
      decoration: InputDecoration(
        labelText:
            widget.isRequired ? '${widget.labelText} *' : widget.labelText,
        border: const OutlineInputBorder(),
        suffixIcon:
            !widget.isRequired && hasValue
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearField,
                )
                : null,
      ),
      items:
          widget.options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.formData[widget.fieldName] = value;
          setState(() {
            _currentValue = value;
          });
        }
      },
      validator:
          widget.isRequired
              ? (value) {
                if (value == null || value.isEmpty || value == 'None') {
                  return 'Required';
                }
                return null;
              }
              : null,
    );
  }
}
