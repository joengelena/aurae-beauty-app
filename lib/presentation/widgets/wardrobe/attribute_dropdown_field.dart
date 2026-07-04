import 'package:flutter/material.dart';

/// Dropdown seeded from DB attribute options with an "Other" escape hatch.
///
/// Selecting "Other" reveals a text field for a custom value. The custom
/// value is stored as-is in user_dresses — it does NOT appear in the filter
/// dropdowns, which read only from the dress_attribute table.
///
/// Falls back to a plain TextFormField when [options] is empty (still loading).
class AttributeDropdownField extends StatefulWidget {
  final String label;

  /// Attribute values from dress_attribute table. Must NOT include 'Any'.
  final List<String> options;

  /// Pre-existing value (edit flow). Matched against [options]; if not found,
  /// falls to 'Other' with custom text pre-populated.
  final String? initialValue;

  final bool required;
  final void Function(String value) onChanged;

  const AttributeDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
    this.required = false,
  });

  @override
  State<AttributeDropdownField> createState() => _AttributeDropdownFieldState();
}

class _AttributeDropdownFieldState extends State<AttributeDropdownField> {
  String? _selected;
  final _customController = TextEditingController();

  bool get _isOther => _selected == 'Other';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    if (v != null && v.isNotEmpty) {
      if (widget.options.contains(v)) {
        _selected = v;
      } else {
        _selected = 'Other';
        _customController.text = v;
      }
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          initialValue: widget.initialValue,
          decoration: InputDecoration(labelText: widget.label),
          validator: widget.required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? '${widget.label} is required'
                  : null
              : null,
          onChanged: (v) => widget.onChanged(v.trim()),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selected,
            decoration: InputDecoration(labelText: widget.label),
            items: widget.options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            validator: widget.required
                ? (v) => v == null ? '${widget.label} is required' : null
                : null,
            onChanged: (v) {
              setState(() {
                _selected = v;
                if (v != 'Other') _customController.clear();
              });
              final resolved = _isOther ? _customController.text.trim() : (v ?? '');
              widget.onChanged(resolved);
            },
          ),
          if (_isOther)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                controller: _customController,
                decoration: InputDecoration(
                  labelText: 'Enter ${widget.label.toLowerCase()}',
                ),
                validator: widget.required
                    ? (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a ${widget.label.toLowerCase()}'
                        : null
                    : null,
                onChanged: (v) => widget.onChanged(v.trim()),
              ),
            ),
        ],
      ),
    );
  }
}
