import 'package:flutter/material.dart';

/// A reusable badge widget for displaying active filters with a remove button
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
    return FilledButton(
      onPressed: onRemove,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.secondary,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(displayText),
          const SizedBox(width: 8),
          const Icon(Icons.close, size: 16),
        ],
      ),
    );
  }
}
