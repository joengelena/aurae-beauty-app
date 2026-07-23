import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Toggleable chip group for picking zero or more values from a fixed list.
/// Used for "Recommended sizes" — a lightweight alternative to typing free
/// text, consistent with the pill vocabulary used by [PickerFormField] and
/// filter badges elsewhere in the app.
class MultiChipSelector extends StatefulWidget {
  final String label;
  final List<String> options;
  final List<String> initialValues;
  final void Function(List<String> values) onChanged;

  const MultiChipSelector({
    super.key,
    required this.label,
    required this.options,
    this.initialValues = const [],
    required this.onChanged,
  });

  @override
  State<MultiChipSelector> createState() => _MultiChipSelectorState();
}

class _MultiChipSelectorState extends State<MultiChipSelector> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValues.toSet();
  }

  @override
  void didUpdateWidget(MultiChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValues != widget.initialValues) {
      _selected = widget.initialValues.toSet();
    }
  }

  void _toggle(String value) {
    setState(() {
      if (!_selected.remove(value)) _selected.add(value);
    });
    widget.onChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: themeTaupe,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((option) {
              final isSelected = _selected.contains(option);
              return GestureDetector(
                onTap: () => _toggle(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? themeAccent.withValues(alpha: 0.18) : Colors.white,
                    border: Border.all(
                      color: isSelected ? themeAccent : themePrimary,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? themeText : themeTaupe,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
