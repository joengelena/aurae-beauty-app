import 'package:flutter/material.dart';
import 'package:shine_app/utils/constants.dart';

/// The app's one card idiom (DESIGN.md "Cards"): white surface, 16px
/// radius, the "Raised" shadow. No border — the shadow provides the lift.
/// Use this instead of a one-off `Container` + `BoxDecoration` so every
/// card in the app looks the same.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacingLarge),
    this.margin,
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
