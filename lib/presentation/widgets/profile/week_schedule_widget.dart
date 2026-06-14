import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/week_schedule_provider.dart';
import 'package:shine_app/utils/theme.dart';

class WeekScheduleWidget extends StatelessWidget {
  const WeekScheduleWidget({super.key});

  static const _dayAbbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeekScheduleProvider>();

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
            _buildDayList(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeekScheduleProvider provider) {
    final start = provider.weekStart;
    final end = provider.weekEnd;
    final rangeLabel = '${start.day} ${_monthAbbrev[start.month - 1]}'
        ' – ${end.day} ${_monthAbbrev[end.month - 1]}';

    return Row(
      children: [
        Text(
          'My Schedule',
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

  Widget _buildDayList(WeekScheduleProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = provider.weekDays;

    return Column(
      children: List.generate(days.length, (i) {
        final day = days[i];
        final isToday = day == today;
        final bookings = provider.bookingsForDay(day);
        return _buildDayRow(day, isToday, bookings, i < days.length - 1);
      }),
    );
  }

  Widget _buildDayRow(
    DateTime day,
    bool isToday,
    List<BookingWithDress> bookings,
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
                        children: bookings
                            .map((b) => _buildBookingChip(b))
                            .toList(),
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

  Widget _buildBookingChip(BookingWithDress b) {
    final Color bgColor;
    final Color textColor;
    final String statusLabel;

    switch (b.booking.status) {
      case 'active':
        bgColor = themePeach.withValues(alpha: 0.22);
        textColor = themeText;
        statusLabel = 'Out';
      case 'confirmed':
      case 'pending':
        bgColor = themeAccent.withValues(alpha: 0.30);
        textColor = themeText;
        statusLabel = 'Booked';
      default:
        bgColor = themePrimary.withValues(alpha: 0.55);
        textColor = themeTaupe;
        statusLabel = b.booking.status;
    }

    final dressName = [b.dress.brand, b.dress.style]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final label = (b.dress.internalName?.isNotEmpty == true)
        ? b.dress.internalName!
        : (dressName.isNotEmpty ? dressName : 'Dress #${b.dress.id}');

    return Container(
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
    );
  }
}
