import 'package:flutter/material.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';

// Priority order matters — higher index wins when days overlap
enum _DayStatus { none, past, pending, booked, active, overdue }

enum _ViewMode { day, week, month }

class BookingCalendar extends StatefulWidget {
  final List<RentalBooking> bookings;

  const BookingCalendar({super.key, required this.bookings});

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late DateTime _month;
  late DateTime _focusedDay;
  _ViewMode _viewMode = _ViewMode.month;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _focusedDay = DateTime(now.year, now.month, now.day);
  }

  DateTime get _weekStart {
    final daysFromMonday = _focusedDay.weekday - DateTime.monday;
    return _focusedDay.subtract(Duration(days: daysFromMonday));
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
        'confirmed' => _DayStatus.booked,
        'pending' => _DayStatus.pending,
        'returned' => _DayStatus.past,
        _ => _DayStatus.none,
      };

      if (status.index > best.index) best = status;
      if (best == _DayStatus.overdue) break;
    }

    return best;
  }

  List<RentalBooking> _bookingsOnDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return widget.bookings.where((b) {
      if (b.status == 'cancelled') return false;
      final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  // Returns start | middle | end | single | none for range pill rendering.
  // Ranges break at week-row boundaries (Mon/Sun) and month edges.
  String _rangeType(DateTime day, _DayStatus status, {bool breakAtMonthEdge = true}) {
    if (status == _DayStatus.none) return 'none';

    final isMonday = day.weekday == DateTime.monday;
    final isSunday = day.weekday == DateTime.sunday;

    final prev = day.subtract(const Duration(days: 1));
    final next = day.add(const Duration(days: 1));

    final connectLeft = !isMonday &&
        (!breakAtMonthEdge || prev.month == day.month) &&
        _getStatus(prev) == status;
    final connectRight = !isSunday &&
        (!breakAtMonthEdge || next.month == day.month) &&
        _getStatus(next) == status;

    if (connectLeft && connectRight) return 'middle';
    if (connectLeft) return 'end';
    if (connectRight) return 'start';
    return 'single';
  }

  void _openDay(DateTime day) {
    setState(() {
      _focusedDay = DateTime(day.year, day.month, day.day);
      _viewMode = _ViewMode.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModeToggle(),
        const SizedBox(height: 12),
        switch (_viewMode) {
          _ViewMode.month => _buildMonthView(),
          _ViewMode.week => _buildWeekView(),
          _ViewMode.day => _buildDayView(),
        },
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFED),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: _ViewMode.values.map(_modeButton).toList(),
      ),
    );
  }

  Widget _modeButton(_ViewMode mode) {
    final selected = _viewMode == mode;
    final label = switch (mode) {
      _ViewMode.day => 'Day',
      _ViewMode.week => 'Week',
      _ViewMode.month => 'Month',
    };
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? themeText : themeTaupe,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Month view ───────────────────────────────────────────────────────────

  Widget _buildMonthView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 10),
        _buildDayLabels(),
        const SizedBox(height: 3),
        _buildMonthGrid(),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        _navButton(
          Icons.chevron_left,
          () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
        ),
        Expanded(
          child: Text(
            '${_monthNames[_month.month - 1]} ${_month.year}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: themeText,
              letterSpacing: 0.1,
            ),
          ),
        ),
        _navButton(
          Icons.chevron_right,
          () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
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
              fontWeight: FontWeight.w600,
              color: themeTaupe,
              letterSpacing: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthGrid() {
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
              return const Expanded(child: SizedBox(height: 36));
            }
            return Expanded(
              child: _buildCell(DateTime(_month.year, _month.month, dayNum)),
            );
          }),
        );
      }),
    );
  }

  // ─── Week view ────────────────────────────────────────────────────────────

  Widget _buildWeekView() {
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _navButton(
              Icons.chevron_left,
              () => setState(() => _focusedDay = _focusedDay.subtract(const Duration(days: 7))),
            ),
            Expanded(
              child: Text(
                start.month == end.month
                    ? '${start.day} – ${end.day} ${_monthAbbrev[start.month - 1]} ${start.year}'
                    : '${start.day} ${_monthAbbrev[start.month - 1]} – ${end.day} ${_monthAbbrev[end.month - 1]} ${end.year}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: themeText,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            _navButton(
              Icons.chevron_right,
              () => setState(() => _focusedDay = _focusedDay.add(const Duration(days: 7))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDayLabels(),
        const SizedBox(height: 3),
        Row(
          children: days
              .map((d) => Expanded(child: _buildCell(d, breakAtMonthEdge: false)))
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  // ─── Day view ─────────────────────────────────────────────────────────────

  Widget _buildDayView() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _focusedDay == today;
    final bookings = _bookingsOnDay(_focusedDay)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _navButton(
              Icons.chevron_left,
              () => setState(() => _focusedDay = _focusedDay.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_focusedDay.day} ${_monthAbbrev[_focusedDay.month - 1]} ${_focusedDay.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: themeText,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (isToday)
                    Text(
                      'Today',
                      style: TextStyle(fontSize: 12, color: themeAccent, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            _navButton(
              Icons.chevron_right,
              () => setState(() => _focusedDay = _focusedDay.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Available — no bookings this day',
                style: TextStyle(fontSize: 12, color: themeTaupe),
              ),
            ),
          )
        else
          ...bookings.map((b) => _dayBookingRow(b)),
      ],
    );
  }

  Widget _dayBookingRow(RentalBooking b) {
    final overdue = _isOverdue(b);
    final Color dot = switch (b.status) {
      'active' => overdue ? themeRose : themePeach,
      'confirmed' || 'pending' => themeAccent,
      'returned' => themeTaupe,
      _ => themeTaupe,
    };
    final label = switch (b.status) {
      'active' => overdue ? 'Overdue' : 'Out for rent',
      'confirmed' => 'Confirmed',
      'pending' => 'Pending',
      'returned' => 'Returned',
      _ => b.status,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.renterName.isNotEmpty ? b.renterName : b.bookingType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeText,
                  ),
                ),
                Text(
                  '${formatDate(b.startDate)} – ${formatDate(b.endDate)} · $label',
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared ───────────────────────────────────────────────────────────────

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Icon(icon, size: 18, color: themeTaupe),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, {bool breakAtMonthEdge = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = DateTime(day.year, day.month, day.day) == today;

    final status = _getStatus(day);
    final range = _rangeType(day, status, breakAtMonthEdge: breakAtMonthEdge);

    final Color fill;
    final Color textColor;
    switch (status) {
      case _DayStatus.active:
        fill = themePeach.withValues(alpha: 0.22);
        textColor = themeText;
      case _DayStatus.booked:
        fill = themeAccent.withValues(alpha: 0.30);
        textColor = themeText;
      case _DayStatus.pending:
        fill = themeAccent.withValues(alpha: 0.12);
        textColor = themeTaupe;
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

    return GestureDetector(
      onTap: () => _openDay(day),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
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
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _legendItem(themeAccent.withValues(alpha: 0.30), 'Booked'),
        _legendItem(themeAccent.withValues(alpha: 0.12), 'Pending'),
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
          style: TextStyle(fontSize: 12, color: themeTaupe),
        ),
      ],
    );
  }
}
