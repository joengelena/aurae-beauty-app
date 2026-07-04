import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
import 'package:shine_app/utils/theme.dart';

/// Collapsible date-range picker using the AvailabilityCalendar.
/// Shows a pill header; tapping expands the calendar for two-tap selection.
class CalendarDateRangePicker extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  /// Called whenever selection changes. Both null when cleared; start non-null
  /// with end null while first date is picked; both non-null when range complete.
  final void Function(DateTime? start, DateTime? end) onChanged;

  /// Dates to mark as unavailable on the calendar.
  final List<BookedRange> bookedRanges;

  final String placeholder;
  final bool hasError;

  const CalendarDateRangePicker({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onChanged,
    this.bookedRanges = const [],
    this.placeholder = 'Select dates',
    this.hasError = false,
  });

  @override
  State<CalendarDateRangePicker> createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  bool _expanded = false;
  DateTime? _start;
  DateTime? _end;

  static final _fmt = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
      } else if (day == _start) {
        _start = null;
      } else {
        _end = day;
        _expanded = false;
      }
    });
    widget.onChanged(_start, _end);
  }

  void _clear() {
    setState(() {
      _start = null;
      _end = null;
      _expanded = false;
    });
    widget.onChanged(null, null);
  }

  String get _label {
    if (_start != null && _end != null) {
      return '${_fmt.format(_start!)} – ${_fmt.format(_end!)}';
    }
    if (_start != null) return '${_fmt.format(_start!)} – ?';
    return widget.placeholder;
  }

  bool get _hasSelection => _start != null || _end != null;
  bool get _isComplete => _start != null && _end != null;

  Color get _borderColor {
    if (widget.hasError) return themeRose;
    if (_isComplete) return themeAccent;
    return themePrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _borderColor,
                width: _isComplete || widget.hasError ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: widget.hasError
                      ? themeRose
                      : (_isComplete ? themeAccent : themeTaupe),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _label,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.hasError
                          ? themeRose
                          : (_hasSelection ? themeText : themeTaupe),
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_hasSelection)
                  GestureDetector(
                    onTap: _clear,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.close, size: 14, color: themeTaupe),
                    ),
                  )
                else
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: widget.hasError ? themeRose : themeTaupe,
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AvailabilityCalendar(
                    bookedRanges: widget.bookedRanges,
                    selectionStart: _start,
                    selectionEnd: _end,
                    onDayTapped: _onDayTapped,
                    showLegend: widget.bookedRanges.isNotEmpty,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
