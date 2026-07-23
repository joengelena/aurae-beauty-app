import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

// Priority order matters — a day can only be one of these, in this precedence
enum _DayStatus { none, notYetAvailable, past }

// Month calendar for "sell" dresses: shows which days are in the past,
// which are blocked until the owner-set `availableFrom` date, and which
// are open for purchase (the unstyled default).
class PurchaseAvailabilityCalendar extends StatefulWidget {
  final DateTime? availableFrom;

  const PurchaseAvailabilityCalendar({super.key, required this.availableFrom});

  @override
  State<PurchaseAvailabilityCalendar> createState() =>
      _PurchaseAvailabilityCalendarState();
}

class _PurchaseAvailabilityCalendarState
    extends State<PurchaseAvailabilityCalendar> {
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

  _DayStatus _getStatus(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);

    if (d.isBefore(today)) return _DayStatus.past;

    final availableFrom = widget.availableFrom;
    if (availableFrom != null) {
      final af = DateTime(availableFrom.year, availableFrom.month, availableFrom.day);
      if (d.isBefore(af)) return _DayStatus.notYetAvailable;
    }

    return _DayStatus.none;
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

  Widget _buildCell(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = DateTime(day.year, day.month, day.day) == today;

    final status = _getStatus(day);
    final range = _rangeType(day, status);

    BorderRadius radius = BorderRadius.zero;
    if (status != _DayStatus.none) {
      radius = switch (range) {
        'single' => BorderRadius.circular(8),
        'start' => const BorderRadius.horizontal(left: Radius.circular(8)),
        'end' => const BorderRadius.horizontal(right: Radius.circular(8)),
        _ => BorderRadius.zero, // middle: square fill, no border radius
      };
    }

    final Color textColor = switch (status) {
      _DayStatus.past => themeTaupe,
      _DayStatus.notYetAvailable => themeTaupe,
      _DayStatus.none => themeText,
    };

    final ringColor = status == _DayStatus.none ? themeAccent : themeText;

    Widget fill;
    switch (status) {
      case _DayStatus.past:
        fill = Container(color: themePrimary.withValues(alpha: 0.55));
      case _DayStatus.notYetAvailable:
        fill = ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: themeTaupe.withValues(alpha: 0.12)),
              CustomPaint(
                painter: _DiagonalStripesPainter(
                  color: themeTaupe.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        );
      case _DayStatus.none:
        fill = const SizedBox.shrink();
    }

    return Container(
      height: 36,
      decoration: status != _DayStatus.none
          ? BoxDecoration(borderRadius: radius)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (status != _DayStatus.none)
            ClipRRect(borderRadius: radius, child: fill),
          Center(
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
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _legendItem(
          Container(color: themePrimary.withValues(alpha: 0.55)),
          'Past',
        ),
        _legendItem(
          Stack(
            fit: StackFit.expand,
            children: [
              Container(color: themeTaupe.withValues(alpha: 0.12)),
              CustomPaint(
                painter: _DiagonalStripesPainter(
                  color: themeTaupe.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          'Not yet available',
        ),
      ],
    );
  }

  Widget _legendItem(Widget swatch, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 10,
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: swatch,
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

// Draws evenly-spaced 45° stripes across the paint bounds — the "not yet
// available" texture that distinguishes it from the solid "past" fill.
class _DiagonalStripesPainter extends CustomPainter {
  final Color color;

  const _DiagonalStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const spacing = 5.0;
    final span = size.width + size.height;
    for (double x = -size.height; x < span; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripesPainter oldDelegate) =>
      oldDelegate.color != color;
}
