import 'package:flutter/material.dart';

/// A reusable floating action button with an icon and label text
///
/// Displays an extended FAB with a plus icon and custom label.
/// Positioned at the bottom-right of the screen.
class LabeledFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const LabeledFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
