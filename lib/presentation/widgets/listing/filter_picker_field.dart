import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Pill-shaped filter field that opens a bottom-sheet single-select list —
/// the Browse-filter counterpart to PickerFormField's field+sheet pattern.
/// Deliberately leaner than PickerFormField: every filter is optional
/// ('Any' is always a valid, pre-supplied option) and its options are a
/// closed, server-provided list, so there's no required-field validation
/// or custom "Other" entry to carry here.
class FilterPickerField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const FilterPickerField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  bool get _isActive => selectedValue != 'Any';

  Future<void> _openSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterPickerSheet(
        title: label,
        options: options,
        selected: selectedValue,
      ),
    );
    if (picked != null && picked != selectedValue) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _isActive ? themeAccent : themePrimary,
            width: _isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
                  color: _isActive ? themeText : themeTaupe,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more_rounded, size: 18, color: themeTaupe),
          ],
        ),
      ),
    );
  }
}

class _FilterPickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;

  const _FilterPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
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
                title,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
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
