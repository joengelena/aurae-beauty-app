import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/my_bookings_provider.dart';
import 'package:shine_app/presentation/widgets/profile/booking_list_card.dart';
import 'package:shine_app/utils/theme.dart';

/// Compact "Bookings" summary for the Profile page: every upcoming booking
/// (including pending review) starting within the next 30 days, dress-first,
/// plus a link to the full My Bookings history. Full management (all
/// bookings, cancel) lives on that page.
class MyBookingsPreviewCard extends StatelessWidget {
  const MyBookingsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyBookingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/bookings'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Bookings', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: themeTaupe,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: themeTaupe),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.hasError)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                provider.errorMessage,
                style: TextStyle(color: themeRose, fontSize: 12),
              ),
            )
          else if (provider.upcomingWithinMonth.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No upcoming bookings in the next month',
                style: TextStyle(color: themeTaupe, fontSize: 12),
              ),
            )
          else
            for (final booking in provider.upcomingWithinMonth)
              BookingListCard(booking: booking),
        ],
      ),
    );
  }
}
