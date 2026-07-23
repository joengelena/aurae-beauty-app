import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Single-select chip group for picking a dress's size. Used with a
/// [SizeSystemToggle] above it, which supplies either the alphabet or
/// numeric list via [options] — visually matches [MultiChipSelector] but
/// only one chip can be selected.
class SizeRadioSelector extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final void Function(String value) onChanged;

  const SizeRadioSelector({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SizeRadioSelector> createState() => _SizeRadioSelectorState();
}

class _SizeRadioSelectorState extends State<SizeRadioSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(SizeRadioSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() => _selected = widget.initialValue);
    }
  }

  void _select(String value) {
    setState(() => _selected = value);
    widget.onChanged(value);
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
              final isSelected = _selected == option;
              return GestureDetector(
                onTap: () => _select(option),
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
