import 'package:flutter/material.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/utils/theme.dart';

// Priority order matters — higher index wins when days overlap
enum _DayStatus { none, past, booked, active, overdue }

class BookingCalendar extends StatefulWidget {
  final List<RentalBooking> bookings;

  const BookingCalendar({super.key, required this.bookings});

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late DateTime _month;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool _isOverdue(RentalBooking b) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return b.status == 'active' &&
        DateTime(b.endDate.year, b.endDate.month, b.endDate.day)
            .isBefore(today);
  }

  _DayStatus _getStatus(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    _DayStatus best = _DayStatus.none;

    for (final b in widget.bookings) {
      if (b.status == 'cancelled') continue;

      final start =
          DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);

      if (d.isBefore(start) || d.isAfter(end)) continue;

      final status = switch (b.status) {
        'active' =>
          _isOverdue(b) ? _DayStatus.overdue : _DayStatus.active,
        'confirmed' || 'pending' => _DayStatus.booked,
        'returned' => _DayStatus.past,
        _ => _DayStatus.none,
      };

      if (status.index > best.index) best = status;
      if (best == _DayStatus.overdue) break;
    }

    return best;
  }

  // Returns start | middle | end | single | none for range pill rendering.
  // Ranges break at week-row boundaries (Mon/Sun) and month edges.
  String _rangeType(DateTime day, _DayStatus status) {
    if (status == _DayStatus.none) return 'none';

    final isMonday = day.weekday == DateTime.monday;
    final isSunday = day.weekday == DateTime.sunday;

    final prev = day.subtract(const Duration(days: 1));
    final next = day.add(const Duration(days: 1));

    final connectLeft = !isMonday &&
        prev.month == day.month &&
        _getStatus(prev) == status;
    final connectRight = !isSunday &&
        next.month == day.month &&
        _getStatus(next) == status;

    if (connectLeft && connectRight) return 'middle';
    if (connectLeft) return 'end';
    if (connectRight) return 'start';
    return 'single';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 10),
        _buildDayLabels(),
        const SizedBox(height: 3),
        _buildGrid(),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _month = DateTime(_month.year, _month.month - 1);
          }),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(Icons.chevron_left, size: 18, color: themeTaupe),
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${_monthNames[_month.month - 1]} ${_month.year}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeText,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _month = DateTime(_month.year, _month.month + 1);
          }),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(Icons.chevron_right, size: 18, color: themeTaupe),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabels() {
    return Row(
      children: _dayLabels.map((l) {
        return Expanded(
          child: Text(
            l,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: themeTaupe,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    // Mon-first grid: weekday 1=Mon → 0 leading cells; 7=Sun → 6 leading cells
    final leadingCells = firstDay.weekday - 1;
    final rows = ((leadingCells + daysInMonth) / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            final dayNum = idx - leadingCells + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 34));
            }
            return Expanded(
              child: _buildCell(DateTime(_month.year, _month.month, dayNum)),
            );
          }),
        );
      }),
    );
  }

  Widget _buildCell(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = DateTime(day.year, day.month, day.day) == today;

    final status = _getStatus(day);
    final range = _rangeType(day, status);

    final Color fill;
    final Color textColor;
    switch (status) {
      case _DayStatus.active:
        fill = themePeach.withValues(alpha: 0.22);
        textColor = themeText;
      case _DayStatus.booked:
        fill = themeAccent.withValues(alpha: 0.30);
        textColor = themeText;
      case _DayStatus.overdue:
        fill = themeRose.withValues(alpha: 0.20);
        textColor = themeRose;
      case _DayStatus.past:
        fill = themePrimary.withValues(alpha: 0.55);
        textColor = themeTaupe;
      case _DayStatus.none:
        fill = Colors.transparent;
        textColor = themeText;
    }

    BorderRadius? radius;
    if (status != _DayStatus.none) {
      radius = switch (range) {
        'single' => BorderRadius.circular(8),
        'start' => const BorderRadius.horizontal(left: Radius.circular(8)),
        'end' => const BorderRadius.horizontal(right: Radius.circular(8)),
        _ => null, // middle: square fill, no border radius
      };
    }

    final ringColor = status == _DayStatus.none ? themeAccent : themeText;

    return Container(
      height: 34,
      decoration: status != _DayStatus.none
          ? BoxDecoration(color: fill, borderRadius: radius)
          : null,
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          decoration: isToday
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 1.5),
                )
              : null,
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _legendItem(themeAccent.withValues(alpha: 0.30), 'Booked'),
        _legendItem(themePeach.withValues(alpha: 0.22), 'Out for rent'),
        _legendItem(themeRose.withValues(alpha: 0.20), 'Overdue'),
        _legendItem(themePrimary.withValues(alpha: 0.55), 'Returned'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: themeTaupe),
        ),
      ],
    );
  }
}
