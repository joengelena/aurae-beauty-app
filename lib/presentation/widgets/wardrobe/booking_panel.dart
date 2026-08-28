import 'package:flutter/material.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/logic/business_settings_provider.dart';
import 'package:shine_app/presentation/widgets/wardrobe/booking_calendar.dart';
import 'package:shine_app/presentation/widgets/wardrobe/purchase_availability_calendar.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

// The primary booking/purchase surface for a dress: price, an availability
// calendar (rental status or purchase availability, depending on
// listingType), and the CTA that starts the flow. Replaces the old
// sticky-bottom price bar so the calendar is visible without scrolling.
class BookingPanel extends StatelessWidget {
  final BusinessDress dress;
  final List<RentalBooking> bookings;
  final VoidCallback onTap;

  const BookingPanel({
    super.key,
    required this.dress,
    required this.bookings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isForSale = dress.listingType == 'sell';
    final price = isForSale
        ? (dress.purchasePrice ?? dress.rentalPricePerDay)
        : dress.rentalPricePerDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (price != null) ...[
            _buildPrice(price, isForSale),
            const SizedBox(height: 16),
          ],
          isForSale
              ? PurchaseAvailabilityCalendar(availableFrom: dress.availableFrom)
              : BookingCalendar(
                  bookings: bookings,
                  // Business-wide, not per-dress — the same setting the API
                  // applies when it refuses a conflicting booking.
                  cleaningBufferDays: context
                      .watch<BusinessSettingsProvider>()
                      .settings
                      .cleaningBufferDays,
                  blockedRanges: dress.blockedDateRanges,
                ),
          const SizedBox(height: 16),
          _buildCta(isForSale),
        ],
      ),
    );
  }

  Widget _buildPrice(int price, bool isForSale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${isForSale ? '' : 'From '}${formatPrice(price)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: themeText,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isForSale ? 'purchase price' : 'per day',
          style: TextStyle(fontSize: 12, color: themeTaupe),
        ),
      ],
    );
  }

  Widget _buildCta(bool isForSale) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: themeText,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isForSale ? Icons.shopping_bag_outlined : Icons.calendar_today_outlined,
                size: 16,
                color: const Color(0xFFFFF8F6),
              ),
              const SizedBox(width: 8),
              Text(
                isForSale ? 'Purchase' : 'Select Dates',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFF8F6),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
