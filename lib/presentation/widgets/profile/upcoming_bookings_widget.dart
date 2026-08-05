import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/logic/upcoming_bookings_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';

enum _ScheduleViewMode { day, week, month }

class UpcomingBookingsWidget extends StatefulWidget {
  const UpcomingBookingsWidget({super.key});

  @override
  State<UpcomingBookingsWidget> createState() => _UpcomingBookingsWidgetState();
}

class _UpcomingBookingsWidgetState extends State<UpcomingBookingsWidget> {
  late DateTime _focusedDay;
  late DateTime _month;
  _ScheduleViewMode _viewMode = _ScheduleViewMode.week;

  static const _dayAbbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    _focusedDay = DateTime(now.year, now.month, now.day);
    _month = DateTime(now.year, now.month);
  }

  DateTime get _weekStart {
    final daysFromMonday = _focusedDay.weekday - DateTime.monday;
    return _focusedDay.subtract(Duration(days: daysFromMonday));
  }

  void _openDay(DateTime day) {
    setState(() {
      _focusedDay = DateTime(day.year, day.month, day.day);
      _viewMode = _ScheduleViewMode.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpcomingBookingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bookings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildModeToggle(),
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
            switch (_viewMode) {
              _ScheduleViewMode.day => _buildDayView(context, provider),
              _ScheduleViewMode.week => _buildWeekView(context, provider),
              _ScheduleViewMode.month => _buildMonthView(context, provider),
            },
        ],
      ),
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
        children: _ScheduleViewMode.values.map(_modeButton).toList(),
      ),
    );
  }

  Widget _modeButton(_ScheduleViewMode mode) {
    final selected = _viewMode == mode;
    final label = switch (mode) {
      _ScheduleViewMode.day => 'Day',
      _ScheduleViewMode.week => 'Week',
      _ScheduleViewMode.month => 'Month',
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

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(child: Icon(icon, size: 18, color: themeTaupe)),
      ),
    );
  }

  // ─── Week view ────────────────────────────────────────────────────────────

  Widget _buildWeekView(BuildContext context, UpcomingBookingsProvider provider) {
    final start = _weekStart;
    final end = start.add(const Duration(days: 6));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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
                    ? '${start.day} – ${end.day} ${_monthAbbrev[start.month - 1]}'
                    : '${start.day} ${_monthAbbrev[start.month - 1]} – ${end.day} ${_monthAbbrev[end.month - 1]}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeText),
              ),
            ),
            _navButton(
              Icons.chevron_right,
              () => setState(() => _focusedDay = _focusedDay.add(const Duration(days: 7))),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Column(
          children: List.generate(days.length, (i) {
            final day = days[i];
            final isToday = day == today;
            final bookings = provider.bookingsForDay(day);
            return _buildDayRow(context, day, isToday, bookings, i < days.length - 1);
          }),
        ),
      ],
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    DateTime day,
    bool isToday,
    List<UpcomingBooking> bookings,
    bool showDivider,
  ) {
    return GestureDetector(
      onTap: () => _openDay(day),
      behavior: HitTestBehavior.opaque,
      child: Column(
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
                              .map((b) => _buildBookingChip(context, b))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(height: 1, color: themePrimary.withValues(alpha: 0.5)),
        ],
      ),
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
        bgColor = themeAccent.withValues(alpha: 0.30);
        textColor = themeText;
        statusLabel = 'Confirmed';
      case 'pending':
        bgColor = themeAccent.withValues(alpha: 0.18);
        textColor = themeText;
        statusLabel = 'Pending approval';
      case 'returned':
        bgColor = const Color(0xFFF5EFED);
        textColor = themeTaupe;
        statusLabel = 'Returned';
      case 'cancelled':
        bgColor = themeRose.withValues(alpha: 0.10);
        textColor = themeRose;
        statusLabel = 'Cancelled';
      default:
        bgColor = themePrimary.withValues(alpha: 0.55);
        textColor = themeTaupe;
        statusLabel = booking.status;
    }

    final label = _dressLabel(booking);

    return GestureDetector(
      onTap: () => _showBookingModal(context, booking, label, bgColor, textColor, statusLabel),
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

  String _dressLabel(UpcomingBooking booking) {
    final dressName = [booking.dressBrand, booking.dressStyle]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return (booking.dressInternalName?.isNotEmpty == true)
        ? booking.dressInternalName!
        : (dressName.isNotEmpty ? dressName : 'Dress #${booking.dressIdFk}');
  }

  // ─── Day view ─────────────────────────────────────────────────────────────

  Widget _buildDayView(BuildContext context, UpcomingBookingsProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _focusedDay == today;
    final bookings = provider.bookingsForDay(_focusedDay);

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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeText),
                  ),
                  if (isToday)
                    Text(
                      'Today',
                      style: TextStyle(fontSize: 11, color: themeAccent, fontWeight: FontWeight.w600),
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
                'Nothing scheduled this day',
                style: TextStyle(fontSize: 12, color: themeTaupe),
              ),
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: bookings.map((b) => _buildBookingChip(context, b)).toList(),
          ),
      ],
    );
  }

  // ─── Month view ───────────────────────────────────────────────────────────

  Widget _buildMonthView(BuildContext context, UpcomingBookingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _navButton(
              Icons.chevron_left,
              () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
            ),
            Expanded(
              child: Text(
                '${_monthNames[_month.month - 1]} ${_month.year}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeText),
              ),
            ),
            _navButton(
              Icons.chevron_right,
              () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _dayAbbrev.map((l) {
            return Expanded(
              child: Text(
                l.substring(0, 1),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: themeTaupe),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 3),
        _buildMonthGrid(provider),
      ],
    );
  }

  Widget _buildMonthGrid(UpcomingBookingsProvider provider) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final leadingCells = firstDay.weekday - 1;
    final rows = ((leadingCells + daysInMonth) / 7).ceil();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            final dayNum = idx - leadingCells + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }
            final day = DateTime(_month.year, _month.month, dayNum);
            final isToday = day == today;
            final count = provider.bookingsForDay(day).length;

            return Expanded(
              child: GestureDetector(
                onTap: () => _openDay(day),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: isToday
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: themeAccent, width: 1.5),
                              )
                            : null,
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                              color: themeText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 5,
                        child: count > 0
                            ? Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: themeAccent,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  void _showBookingModal(
    BuildContext context,
    UpcomingBooking booking,
    String dressLabel,
    Color statusBg,
    Color statusFg,
    String statusLabel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themePrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dressLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_fmtDate(booking.startDate)} – ${_fmtDate(booking.endDate)}',
                style: TextStyle(fontSize: 13, color: themeTaupe),
              ),
              const SizedBox(height: 16),
              Divider(color: themePrimary, thickness: 1),
              const SizedBox(height: 16),
              _infoRow(Icons.payments_outlined, formatPrice(booking.totalCost.toInt())),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _infoRow(Icons.notes_outlined, booking.notes!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.push('/listings/${booking.dressIdFk}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: themeText,
                    foregroundColor: themeBackground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View dress'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: themeTaupe),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: themeText),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_monthAbbrev[d.month - 1]}';
}
