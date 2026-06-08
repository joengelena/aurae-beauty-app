import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

/// A reusable chip widget for displaying active filters with a remove button
class FilterBadge extends StatelessWidget {
  final String displayText;
  final VoidCallback onRemove;

  const FilterBadge({
    super.key,
    required this.displayText,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: themeAccent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeAccent, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayText,
              style: TextStyle(
                color: themeText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.close, size: 14, color: themeTaupe),
          ],
        ),
      ),
    );
  }
}
