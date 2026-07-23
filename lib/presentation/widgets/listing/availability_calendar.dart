import 'package:flutter/material.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/utils/theme.dart';

enum _DayState { past, unavailable, available }

class AvailabilityCalendar extends StatefulWidget {
  final List<BookedRange> bookedRanges;

  /// When provided, the calendar becomes interactive for date-range selection.
  final DateTime? selectionStart;
  final DateTime? selectionEnd;
  final void Function(DateTime day)? onDayTapped;
  final bool showLegend;

  const AvailabilityCalendar({
    super.key,
    required this.bookedRanges,
    this.selectionStart,
    this.selectionEnd,
    this.onDayTapped,
    this.showLegend = true,
  });

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _month;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  bool get _isSelectable => widget.onDayTapped != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  _DayState _getState(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (d.isBefore(today)) return _DayState.past;

    for (final range in widget.bookedRanges) {
      if (!range.isUnavailable) continue;
      final start = DateTime(range.startDate.year, range.startDate.month, range.startDate.day);
      final end = DateTime(range.endDate.year, range.endDate.month, range.endDate.day);
      if (!d.isBefore(start) && !d.isAfter(end)) return _DayState.unavailable;
    }

    return _DayState.available;
  }

  bool _isInSelection(DateTime day) {
    final start = widget.selectionStart;
    final end = widget.selectionEnd;
    if (start == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    if (end == null) return d == s;
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool _isSelectionEdge(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final start = widget.selectionStart;
    final end = widget.selectionEnd;
    if (start != null && d == DateTime(start.year, start.month, start.day)) return true;
    if (end != null && d == DateTime(end.year, end.month, end.day)) return true;
    return false;
  }

  // Range-pill type for unavailable days, breaking at Mon/Sun and month edges.
  String _unavailableRangeType(DateTime day) {
    final isMonday = day.weekday == DateTime.monday;
    final isSunday = day.weekday == DateTime.sunday;
    final prev = day.subtract(const Duration(days: 1));
    final next = day.add(const Duration(days: 1));

    final connectLeft = !isMonday &&
        prev.month == day.month &&
        _getState(prev) == _DayState.unavailable;
    final connectRight = !isSunday &&
        next.month == day.month &&
        _getState(next) == _DayState.unavailable;

    if (connectLeft && connectRight) return 'middle';
    if (connectLeft) return 'end';
    if (connectRight) return 'start';
    return 'single';
  }

  // Range-pill type for selected days.
  String _selectionRangeType(DateTime day) {
    final start = widget.selectionStart;
    final end = widget.selectionEnd;
    if (start == null) return 'single';
    if (end == null) return 'single';

    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    final isMonday = day.weekday == DateTime.monday;
    final isSunday = day.weekday == DateTime.sunday;

    final atStart = d == s;
    final atEnd = d == e;

    if (atStart && atEnd) return 'single';

    final connectLeft = !atStart && !isMonday;
    final connectRight = !atEnd && !isSunday;

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
        if (widget.showLegend) ...[
          const SizedBox(height: 12),
          _buildLegend(),
        ],
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: themeText,
              letterSpacing: 0.1,
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
              fontWeight: FontWeight.w600,
              color: themeTaupe,
              letterSpacing: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
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
            // _buildCell already returns an Expanded-wrapped widget.
            return _buildCell(DateTime(_month.year, _month.month, dayNum));
          }),
        );
      }),
    );
  }

  Widget _buildCell(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = DateTime(day.year, day.month, day.day) == today;

    final state = _getState(day);
    final inSelection = _isInSelection(day);
    final isEdge = _isSelectionEdge(day);
    final tappable = _isSelectable && state == _DayState.available;

    Widget cell;

    if (inSelection) {
      // Selected range rendering
      final rangeType = _selectionRangeType(day);
      final BorderRadius? radius = switch (rangeType) {
        'single' => BorderRadius.circular(8),
        'start' => const BorderRadius.horizontal(left: Radius.circular(8)),
        'end' => const BorderRadius.horizontal(right: Radius.circular(8)),
        _ => null,
      };

      cell = Container(
        height: 36,
        decoration: BoxDecoration(
          color: themeAccent.withValues(alpha: 0.45),
          borderRadius: radius,
        ),
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: isEdge
                ? BoxDecoration(
                    color: themeAccent,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isEdge ? FontWeight.w700 : FontWeight.w500,
                  color: isEdge ? Colors.white : themeText,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (state == _DayState.unavailable) {
      final rangeType = _unavailableRangeType(day);
      final BorderRadius? radius = switch (rangeType) {
        'single' => BorderRadius.circular(8),
        'start' => const BorderRadius.horizontal(left: Radius.circular(8)),
        'end' => const BorderRadius.horizontal(right: Radius.circular(8)),
        _ => null,
      };

      cell = Container(
        height: 36,
        decoration: BoxDecoration(
          color: themeAccent.withValues(alpha: 0.30),
          borderRadius: radius,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: themeText,
            ),
          ),
        ),
      );
    } else {
      // Available or past
      final textColor = state == _DayState.past
          ? themeTaupe.withValues(alpha: 0.4)
          : themeText;

      cell = SizedBox(
        height: 36,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: isToday && state != _DayState.past
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: themeAccent, width: 1.5),
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

    if (tappable) {
      return Expanded(
        child: GestureDetector(
          onTap: () => widget.onDayTapped!(day),
          behavior: HitTestBehavior.opaque,
          child: cell,
        ),
      );
    }

    return Expanded(child: cell);
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _legendItem(themeAccent.withValues(alpha: 0.30), 'Unavailable'),
        if (_isSelectable)
          _legendItem(themeAccent.withValues(alpha: 0.45), 'Selected'),
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
        Text(label, style: TextStyle(fontSize: 11, color: themeTaupe)),
      ],
    );
  }
}
