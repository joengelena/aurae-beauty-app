import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/logic/upcoming_bookings_provider.dart';
import 'package:shine_app/utils/theme.dart';

class UpcomingBookingsWidget extends StatelessWidget {
  const UpcomingBookingsWidget({super.key});

  static const _dayAbbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpcomingBookingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, provider),
          const SizedBox(height: 12),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.hasError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.errorMessage,
                style: TextStyle(color: themeRose, fontSize: 13),
              ),
            )
          else
            _buildDayList(context, provider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UpcomingBookingsProvider provider) {
    final start = provider.weekStart;
    final end = provider.weekEnd;
    final rangeLabel = '${start.day} ${_monthAbbrev[start.month - 1]}'
        ' – ${end.day} ${_monthAbbrev[end.month - 1]}';

    return Row(
      children: [
        Text(
          'Upcoming Bookings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          rangeLabel,
          style: TextStyle(fontSize: 12, color: themeTaupe),
        ),
      ],
    );
  }

  Widget _buildDayList(BuildContext context, UpcomingBookingsProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = provider.weekDays;

    return Column(
      children: List.generate(days.length, (i) {
        final day = days[i];
        final isToday = day == today;
        final bookings = provider.bookingsForDay(day);
        return _buildDayRow(context, day, isToday, bookings, i < days.length - 1);
      }),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    DateTime day,
    bool isToday,
    List<UpcomingBooking> bookings,
    bool showDivider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayLabel(day, isToday),
              const SizedBox(width: 16),
              Expanded(
                child: bookings.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '—',
                          style: TextStyle(color: themeTaupe, fontSize: 13),
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: bookings.map((b) => _buildBookingChip(context, b)).toList(),
                      ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: themePrimary.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _buildDayLabel(DateTime day, bool isToday) {
    final abbrev = _dayAbbrev[day.weekday - 1];

    return SizedBox(
      width: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            abbrev,
            style: TextStyle(
              fontSize: 11,
              color: isToday ? themeAccent.withValues(alpha: 0.8) : themeTaupe,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? themeText : themeText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingChip(BuildContext context, UpcomingBooking booking) {
    final Color bgColor;
    final Color textColor;
    final String statusLabel;

    switch (booking.status) {
      case 'active':
        bgColor = themePeach.withValues(alpha: 0.22);
        textColor = themeText;
        statusLabel = 'Active';
      case 'confirmed':
      case 'pending':
        bgColor = themeAccent.withValues(alpha: 0.30);
        textColor = themeText;
        statusLabel = 'Confirmed';
      default:
        bgColor = themePrimary.withValues(alpha: 0.55);
        textColor = themeTaupe;
        statusLabel = booking.status;
    }

    final dressName = [booking.dressBrand, booking.dressStyle]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final label = (booking.dressInternalName?.isNotEmpty == true)
        ? booking.dressInternalName!
        : (dressName.isNotEmpty ? dressName : 'Dress #${booking.dressIdFk}');

    return GestureDetector(
      onTap: () => context.push('/listings/${booking.dressIdFk}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '· $statusLabel',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
