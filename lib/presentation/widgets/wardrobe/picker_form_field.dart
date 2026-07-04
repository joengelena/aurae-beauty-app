import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Pill-shaped form field that opens a bottom-sheet picker instead of
/// the native full-page dropdown overlay.
///
/// If 'Other' is present in [options], selecting it reveals a text input
/// below the pill for a custom value. The custom value is what gets saved
/// to the DB; it never appears in the dress_attribute filter options.
class PickerFormField extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final bool required;
  final void Function(String value) onChanged;

  const PickerFormField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
    this.required = false,
  });

  @override
  State<PickerFormField> createState() => _PickerFormFieldState();
}

class _PickerFormFieldState extends State<PickerFormField> {
  String? _selected;
  final _customController = TextEditingController();

  bool get _hasOtherOption => widget.options.contains('Other');
  bool get _isOther => _selected == 'Other';

  @override
  void initState() {
    super.initState();
    _initFromValue(widget.initialValue);
  }

  void _initFromValue(String? value) {
    if (value == null || value.isEmpty) return;
    if (widget.options.contains(value)) {
      _selected = value;
    } else if (_hasOtherOption) {
      _selected = 'Other';
      _customController.text = value;
    }
  }

  @override
  void didUpdateWidget(PickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we fell back to 'Other' because options hadn't loaded yet,
    // upgrade to a real selection once options arrive.
    if (_isOther &&
        _customController.text.isNotEmpty &&
        widget.options.contains(_customController.text)) {
      setState(() {
        _selected = _customController.text;
        _customController.clear();
      });
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormField<String>(
            initialValue: _selected,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.required
                ? (_) => _selected == null
                    ? '${widget.label} is required'
                    : null
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => _PickerSheet(
                        label: widget.label,
                        options: widget.options,
                        selected: _selected,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _selected = picked;
                        if (picked != 'Other') _customController.clear();
                      });
                      field.didChange(picked);
                      if (picked != 'Other') widget.onChanged(picked);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: field.hasError
                            ? themeRose
                            : _selected != null && !_isOther
                                ? themeAccent
                                : themePrimary,
                        width: field.hasError || (_selected != null && !_isOther)
                            ? 1.5
                            : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selected == null
                                ? widget.label
                                : _isOther
                                    ? (_customController.text.isEmpty
                                        ? 'Other — enter below'
                                        : _customController.text)
                                    : _selected!,
                            style: TextStyle(
                              fontSize: 14,
                              color: _selected == null ? themeTaupe : themeText,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.expand_more_rounded, size: 18, color: themeTaupe),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(fontSize: 12, color: themeRose),
                    ),
                  ),
              ],
            ),
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
                onChanged: (v) {
                  setState(() {}); // refresh pill display text
                  widget.onChanged(v.trim());
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selected;

  const _PickerSheet({
    required this.label,
    required this.options,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: themePrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeText,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: themePrimary.withValues(alpha: 0.6)),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: options.length,
              itemBuilder: (_, i) {
                final opt = options[i];
                final isSelected = opt == selected;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, size: 18, color: themeAccent)
                      : null,
                  onTap: () => Navigator.pop(context, opt),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
