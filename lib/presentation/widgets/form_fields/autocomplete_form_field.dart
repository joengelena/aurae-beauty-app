import 'package:flutter/material.dart';
import 'package:shine_app/logic/form_data_provider.dart';
import 'package:provider/provider.dart';

/// A reusable autocomplete form field that integrates with FormDataProvider.
///
/// Allows users to either type a custom value or select from predefined options.
/// Options are filtered as the user types.
class AutocompleteFormField<T extends FormDataProvider> extends StatefulWidget {
  final String labelText;
  final String fieldName;
  final List<String> options;
  final bool isRequired;
  final String? hintText;
  final IconData? prefixIcon;
  final TextCapitalization textCapitalization;

  const AutocompleteFormField({
    super.key,
    required this.labelText,
    required this.fieldName,
    required this.options,
    this.isRequired = false,
    this.hintText,
    this.prefixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AutocompleteFormField<T>> createState() =>
      _AutocompleteFormFieldState<T>();
}

class _AutocompleteFormFieldState<T extends FormDataProvider>
    extends State<AutocompleteFormField<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial value from provider
    final provider = context.read<T>();
    final savedValue = provider.formData[widget.fieldName] as String?;
    if (savedValue != null) {
      _controller.text = savedValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return widget.options;
        }
        return widget.options.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        // Get the width of the text field to match dropdown width
        final RenderBox? renderBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        final fieldWidth = renderBox?.size.width ?? 300;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              width: fieldWidth,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(option),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      onSelected: (String selection) {
        _controller.text = selection;
        provider.formData[widget.fieldName] = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sync the autocomplete controller with our controller
        if (_controller.text.isNotEmpty &&
            fieldTextEditingController.text.isEmpty) {
          fieldTextEditingController.text = _controller.text;
        }

        // Update both controllers and provider when text changes
        fieldTextEditingController.addListener(() {
          _controller.text = fieldTextEditingController.text;
          provider.formData[widget.fieldName] = fieldTextEditingController.text;
        });

        return Container(
          key: _fieldKey,
          child: TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: widget.isRequired
                  ? '${widget.labelText} *'
                  : widget.labelText,
              border: const OutlineInputBorder(),
              prefixIcon:
                  widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              hintText: widget.hintText,
            ),
            validator: widget.isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  }
                : null,
            textCapitalization: widget.textCapitalization,
          ),
        );
      },
    );
  }
}
