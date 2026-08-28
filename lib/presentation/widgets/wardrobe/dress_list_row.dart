import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

/// The compact counterpart to [DressCard], for scanning stock rather than
/// admiring it.
///
/// Everything acted on survives the shrink — the thumbnail, because a dress is
/// recognised by sight before it is by name, and the pending-booking and
/// damage flags, because those are the reason an owner opens this page. What
/// goes is the space: one row, roughly a third of a card's height.
class DressListRow extends StatelessWidget {
  final BusinessDress dress;
  final Widget actionButton;

  const DressListRow({
    super.key,
    required this.dress,
    required this.actionButton,
  });

  static const double _thumbSize = 56;

  void _openDress(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/${dress.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isSold = dress.status == 'sold';
    final needsAttention =
        dress.pendingBookingCount > 0 || dress.unresolvedDamageCount > 0;

    return InkWell(
      onTap: () => _openDress(context),
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isSold ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _thumbSize,
                  height: _thumbSize,
                  child: ColoredBox(
                    color: themeSurfaceMuted,
                    child: dress.dressPhotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dress.dressPhotoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.checkroom_outlined,
                                    size: 20, color: themeTaupe),
                          )
                        : Icon(Icons.checkroom_outlined,
                            size: 20, color: themeTaupe),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dress.name?.isNotEmpty == true ? dress.name! : dress.brand,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(),
                      style: TextStyle(fontSize: 12, color: themeTaupe, height: 1.25),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (needsAttention) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (dress.pendingBookingCount > 0)
                            _badge(
                              icon: Icons.hourglass_empty,
                              label: '${dress.pendingBookingCount}',
                              background: themeAccent.withValues(alpha: 0.92),
                              foreground: themeText,
                              tooltip: dress.pendingBookingCount > 1
                                  ? '${dress.pendingBookingCount} bookings to review'
                                  : '1 booking to review',
                            ),
                          if (dress.unresolvedDamageCount > 0)
                            _badge(
                              icon: Icons.warning_amber_outlined,
                              label: '${dress.unresolvedDamageCount}',
                              background: themeRose.withValues(alpha: 0.88),
                              foreground: Colors.white,
                              tooltip: dress.unresolvedDamageCount > 1
                                  ? '${dress.unresolvedDamageCount} damage reports'
                                  : 'Damage noted',
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dress.rentalPricePerDay != null)
                    Text(
                      dress.listingType == 'sell'
                          ? formatPrice(dress.rentalPricePerDay!)
                          : '${formatPrice(dress.rentalPricePerDay!)}/day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: themeText,
                      ),
                    ),
                  if (isSold)
                    Text(
                      'Sold',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: themeTaupe,
                      ),
                    ),
                ],
              ),
              actionButton,
            ],
          ),
        ),
      ),
    );
  }

  /// Brand, size and colour on one line — the three things that tell two
  /// similar dresses apart at a glance.
  String _subtitle() {
    final parts = <String>[
      if (dress.name?.isNotEmpty == true) dress.brand,
      'Size ${dress.size}',
      if (dress.color != null && dress.color!.isNotEmpty) dress.color!,
    ];
    return parts.join(' · ');
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: foreground),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
