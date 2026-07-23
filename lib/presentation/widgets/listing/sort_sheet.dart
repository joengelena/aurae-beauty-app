import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Bottom-sheet single-select list for choosing how Browse results are
/// sorted. Mirrors the drag-handle + header + divider + checkmark-row
/// pattern PickerFormField uses elsewhere in the app, so sort reads as
/// part of the same system instead of a native dropdown.
class SortSheet extends StatelessWidget {
  final Map<String, String> optionsByLabel;
  final String selectedValue;

  const SortSheet({
    super.key,
    required this.optionsByLabel,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                'Sort by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeText,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: themePrimary.withValues(alpha: 0.6)),
          ...optionsByLabel.entries.map((entry) {
            final isSelected = entry.value == selectedValue;
            return ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              title: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 14,
                  color: themeText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, size: 18, color: themeAccent)
                  : null,
              onTap: () => Navigator.pop(context, entry.value),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
