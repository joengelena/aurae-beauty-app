import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// Which sizing vocabulary the Size / Recommended sizes chips are drawn
/// from. A dress is described with one system at a time.
enum SizeSystem { letter, number }

/// Segmented pill toggle shared by the Size and Recommended sizes fields —
/// one toggle controls which row of size chips (alphabet or numeric) both
/// fields show, matching the [_toggleOption] pill style used for the
/// For Rent / For Sale toggle elsewhere on these forms.
class SizeSystemToggle extends StatelessWidget {
  final SizeSystem value;
  final void Function(SizeSystem value) onChanged;

  const SizeSystemToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFED),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _option(SizeSystem.letter, 'Alphabet'),
          _option(SizeSystem.number, 'Numeric'),
        ],
      ),
    );
  }

  Widget _option(SizeSystem option, String label) {
    final selected = value == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? themeText : themeTaupe,
            ),
          ),
        ),
      ),
    );
  }
}
