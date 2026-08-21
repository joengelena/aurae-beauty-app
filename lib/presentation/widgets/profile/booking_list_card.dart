import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/presentation/widgets/common/app_card.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';

class _StatusStyle {
  const _StatusStyle(this.background, this.foreground, this.label);
  final Color background;
  final Color foreground;
  final String label;
}

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'active':
      return _StatusStyle(themePeach.withValues(alpha: 0.22), themeText, 'Active');
    case 'confirmed':
      return _StatusStyle(themeAccent.withValues(alpha: 0.30), themeText, 'Confirmed');
    case 'pending':
      return _StatusStyle(themeAccent.withValues(alpha: 0.18), themeText, 'Pending approval');
    case 'returned':
      return _StatusStyle(themeSurfaceMuted, themeTaupe, 'Returned');
    case 'cancelled':
      return _StatusStyle(themeRose.withValues(alpha: 0.10), themeRose, 'Cancelled');
    default:
      return _StatusStyle(themePrimary.withValues(alpha: 0.55), themeTaupe, status);
  }
}

String dressLabel(UpcomingBooking booking) {
  final dressName = [booking.dressBrand, booking.dressStyle]
      .where((s) => s.isNotEmpty)
      .join(' ');
  return (booking.dressInternalName?.isNotEmpty == true)
      ? booking.dressInternalName!
      : (dressName.isNotEmpty ? dressName : 'Dress #${booking.dressIdFk}');
}

String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// A dress-first row for a single booking: photo, dress name, status,
/// date range, and (for cancellable bookings) a cancel action.
class BookingListCard extends StatelessWidget {
  const BookingListCard({
    super.key,
    required this.booking,
    this.showCancel = false,
    this.onCancel,
  });

  final UpcomingBooking booking;
  final bool showCancel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(booking.status);
    final label = dressLabel(booking);

    return AppCard(
      onTap: () => context.push('/listings/${booking.dressIdFk}'),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56 / AppConstants.listingImageAspectRatio,
              child: booking.dressPhotoUrl != null
                  ? ColoredBox(
                      color: themeSurfaceMuted,
                      child: CachedNetworkImage(
                        imageUrl: booking.dressPhotoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _photoPlaceholder(),
                      ),
                    )
                  : _photoPlaceholder(),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: status.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmtDate(booking.startDate)} – ${_fmtDate(booking.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  formatPrice(booking.totalCost.toInt()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (showCancel) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: themeRose,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cancel booking',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return ColoredBox(
      color: themeSurfaceMuted,
      child: Icon(Icons.checkroom_outlined, size: 20, color: themeTaupe.withValues(alpha: 0.6)),
    );
  }
}
