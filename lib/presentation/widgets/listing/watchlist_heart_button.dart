import 'package:flutter/material.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';

/// The app's one favourite/save control, shared by the Browse grid tile
/// (`ListingPreview`) and the Favourites list tile (`ListingTile`). Both used
/// to hand-roll their own heart and had drifted apart — 18px vs 24px icon,
/// rose vs blush when saved, and only Browse had a backing disc.
///
/// The white disc is always present. On Browse the heart sits on top of a
/// dress photo and needs a consistent ground to stay legible; Favourites
/// carries the same disc so the two tabs read identically.
///
/// [isSaved] drives the filled/outlined state. On Favourites every item is
/// saved by definition, so it passes `true` and the tap removes the item.
class WatchlistHeartButton extends StatelessWidget {
  const WatchlistHeartButton({
    super.key,
    required this.isSaved,
    required this.onPressed,
    this.tooltip,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final label =
        tooltip ?? (isSaved ? 'Remove from favourites' : 'Save to favourites');

    // Sized to AppConstants.minTapTarget so the disc and the tap target are
    // the same 44pt circle — DESIGN.md requires 44pt minimum, and a heart this
    // small would otherwise fall well under it. Carries its own Material so
    // the ink splash works on Browse, where there's no Material ancestor.
    return Tooltip(
      message: label,
      child: SizedBox(
        width: AppConstants.minTapTarget,
        height: AppConstants.minTapTarget,
        child: Material(
          color: Colors.white.withValues(alpha: 0.88),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          // The "Raised" shadow. Without it the disc is invisible on
          // Favourites, where the heart lands on the white card body rather
          // than on a dress photo — an 88%-white circle on a white surface.
          elevation: AppConstants.cardShadowElevation,
          shadowColor: Colors.black.withValues(alpha: 0.07),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: isSaved ? themeAccent : themeTaupe,
                size: AppConstants.heartIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
