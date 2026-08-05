import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class DressCard extends StatelessWidget {
  final BusinessDress dress;
  final Widget actionButton;

  const DressCard({super.key, required this.dress, required this.actionButton});

  @override
  Widget build(BuildContext context) {
    final isSold = dress.status == 'sold';

    return GestureDetector(
      onTap: () {
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);
        context.go('/wardrobe/${dress.id}');
      },
      child: Opacity(
        opacity: isSold ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with optional damage indicator
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: AppConstants.listingImageAspectRatio,
                      child:
                          dress.dressPhotoUrl != null
                              ? ColoredBox(
                                color: const Color(0xFFF5EFED),
                                child: CachedNetworkImage(
                                  imageUrl: dress.dressPhotoUrl!,
                                  fit: BoxFit.contain,
                                  errorWidget:
                                      (_, __, ___) => _photoPlaceholder(),
                                ),
                              )
                              : _photoPlaceholder(),
                    ),
                  ),
                  if (isSold)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeText.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Sold',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    )
                  else if (dress.listingType == 'sell')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD0C8C0),
                            width: 0.75,
                          ),
                        ),
                        child: Text(
                          'For Sale',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: themeText,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  if (dress.unresolvedDamageCount > 0)
                    Positioned(
                      top: (isSold || dress.listingType == 'sell') ? 36 : 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeRose.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_outlined,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              dress.unresolvedDamageCount > 1
                                  ? '${dress.unresolvedDamageCount} damage reports'
                                  : 'Damage noted',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (dress.pendingBookingCount > 0)
                    Positioned(
                      top: 8 +
                          ((isSold || dress.listingType == 'sell') ? 28 : 0) +
                          (dress.unresolvedDamageCount > 0 ? 28 : 0),
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeAccent.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 11,
                              color: themeText,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              dress.pendingBookingCount > 1
                                  ? '${dress.pendingBookingCount} bookings to review'
                                  : '1 booking to review',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: themeText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content area — right padding is 2 to give the action button room
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 2, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + action menu in one row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: _buildName()), actionButton],
                    ),

                    const SizedBox(height: 6),

                    // Size, color, condition chips
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _chip(dress.size),
                          if (dress.color != null) _chip(dress.color!),
                          _conditionChip(dress.condition),
                        ],
                      ),
                    ),

                    if (dress.rentalPricePerDay != null ||
                        (dress.rentalCount ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            if (dress.rentalPricePerDay != null) ...[
                              if (dress.listingType != 'sell')
                                Text(
                                  'From ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeTaupe,
                                  ),
                                ),
                              Text(
                                formatPrice(dress.rentalPricePerDay!),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: themeText,
                                ),
                              ),
                              if (dress.listingType != 'sell')
                                Text(
                                  '/day',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeTaupe,
                                  ),
                                ),
                            ],
                            const Spacer(),
                            if (dress.listingType == 'rent' &&
                                (dress.rentalCount ?? 0) > 0)
                              Text(
                                '${dress.rentalCount} rental${dress.rentalCount != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeTaupe,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    final publicName = dress.name?.isNotEmpty == true ? dress.name! : null;
    final primaryLabel = publicName ?? dress.brand;
    final hasInternal = dress.internalName?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          TextSpan(
            children: [
              TextSpan(
                text: primaryLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeText,
                  height: 1.3,
                ),
              ),
              if (hasInternal)
                TextSpan(
                  text: ' (${dress.internalName})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: themeTaupe,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${dress.brand} · ${dress.style}',
          style: TextStyle(fontSize: 11, color: themeTaupe, height: 1.3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: themeTaupe)),
    );
  }

  Widget _conditionChip(String condition) {
    final lower = condition.toLowerCase();
    final Color bg;
    final Color text;
    if (lower == 'poor' || lower == 'damaged') {
      bg = themeRose.withValues(alpha: 0.10);
      text = themeRose;
    } else if (lower == 'fair') {
      bg = themePeach.withValues(alpha: 0.12);
      text = themePeach;
    } else {
      bg = const Color(0xFFF5EFED);
      text = themeTaupe;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(condition, style: TextStyle(fontSize: 11, color: text)),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFF5EFED),
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 40),
      ),
    );
  }
}
