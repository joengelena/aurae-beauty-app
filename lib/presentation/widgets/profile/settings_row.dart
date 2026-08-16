import 'package:flutter/material.dart';
import 'package:shine_app/presentation/widgets/common/app_card.dart';
import 'package:shine_app/utils/theme.dart';

/// A tappable row for account/settings screens: icon in a soft square,
/// label, and an optional trailing chevron for rows that navigate deeper.
/// Set [destructive] for actions like sign out or delete account.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;
  final bool destructive;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = destructive ? themeRose : themeTaupe;
    final labelColor = destructive ? themeRose : themeText;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: themeSurfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
          if (showChevron)
            Icon(Icons.chevron_right, color: themeTaupe, size: 20),
        ],
      ),
    );
  }
}
