import 'package:flutter/material.dart';

/// Represents a single menu option in the action menu
class MenuOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });
}

/// A reusable widget that displays a three-dot menu button
/// When clicked, shows a bottom sheet with the provided menu options
class ActionMenuButton extends StatelessWidget {
  final List<MenuOption> options;
  final String? sheetTitle;

  const ActionMenuButton({
    super.key,
    required this.options,
    this.sheetTitle = 'Options',
  });

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sheetTitle != null)
                Text(
                  sheetTitle!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ...options.map((option) {
                return ListTile(
                  leading: Icon(
                    option.icon,
                    color: option.iconColor,
                  ),
                  title: Text(
                    option.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: option.titleColor,
                        ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    option.onTap();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showBottomSheet(context),
      icon: const Icon(Icons.more_vert),
    );
  }
}
