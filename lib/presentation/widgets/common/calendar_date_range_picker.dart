import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
import 'package:shine_app/utils/date_range_selection.dart';
import 'package:shine_app/utils/theme.dart';

/// Date picker with a pill header using the AvailabilityCalendar.
/// In range mode (default), tapping a day selects that day plus the next as
/// a one-night stay; tapping a later day extends the return date. In
/// single-date mode, one tap picks the date.
/// By default the calendar expands inline below the header; when [popup] is
/// true it opens in a dialog instead, using the same calendar look.
class CalendarDateRangePicker extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  /// Called whenever selection changes. Both null when cleared; start non-null
  /// with end null while first date is picked (or in single-date mode); both
  /// non-null when a range is complete.
  final void Function(DateTime? start, DateTime? end) onChanged;

  /// Dates to mark as unavailable on the calendar.
  final List<BookedRange> bookedRanges;

  final String placeholder;
  final bool hasError;

  /// When false, the calendar picks a single date (one tap) instead of a
  /// start/end range.
  final bool rangeMode;

  /// Label format for the selected date(s). Defaults to 'd MMM'.
  final DateFormat? labelFormat;

  /// When true, tapping the header opens the calendar in a dialog instead
  /// of expanding it inline.
  final bool popup;

  const CalendarDateRangePicker({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onChanged,
    this.bookedRanges = const [],
    this.placeholder = 'Select dates',
    this.hasError = false,
    this.rangeMode = true,
    this.labelFormat,
    this.popup = false,
  });

  @override
  State<CalendarDateRangePicker> createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  bool _expanded = false;
  DateTime? _start;
  DateTime? _end;

  static final _defaultFmt = DateFormat('d MMM');
  DateFormat get _fmt => widget.labelFormat ?? _defaultFmt;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onDayTapped(DateTime day) {
    if (!widget.rangeMode) {
      setState(() {
        _start = (_start != null && day == _start) ? null : day;
        _end = null;
        _expanded = false;
      });
      widget.onChanged(_start, null);
      return;
    }
    final (start, end) = DateRangeSelection.onDayTapped(
      start: _start,
      end: _end,
      day: day,
      bookedRanges: widget.bookedRanges,
    );
    setState(() {
      _start = start;
      _end = end;
      if (_start != null && _end != null) _expanded = false;
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

  Future<void> _openPopup() async {
    final result = await showDialog<(DateTime?, DateTime?)>(
      context: context,
      builder: (_) => _CalendarPickerDialog(
        initialStart: _start,
        initialEnd: _end,
        bookedRanges: widget.bookedRanges,
        rangeMode: widget.rangeMode,
      ),
    );
    if (result == null) return;
    setState(() {
      _start = result.$1;
      _end = result.$2;
    });
    widget.onChanged(_start, _end);
  }

  String get _label {
    if (!widget.rangeMode) {
      return _start != null ? _fmt.format(_start!) : widget.placeholder;
    }
    if (_start != null && _end != null) {
      return '${_fmt.format(_start!)} – ${_fmt.format(_end!)}';
    }
    if (_start != null) return '${_fmt.format(_start!)} – ?';
    return widget.placeholder;
  }

  bool get _hasSelection => _start != null || _end != null;
  bool get _isComplete =>
      widget.rangeMode ? (_start != null && _end != null) : _start != null;

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
          onTap: widget.popup
              ? _openPopup
              : () => setState(() => _expanded = !_expanded),
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
                      fontSize: 14,
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
                else if (!widget.popup)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: widget.hasError ? themeRose : themeTaupe,
                  ),
              ],
            ),
          ),
        ),
        if (!widget.popup)
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

/// Dialog wrapping the same AvailabilityCalendar look, used when
/// [CalendarDateRangePicker.popup] is true.
class _CalendarPickerDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final List<BookedRange> bookedRanges;
  final bool rangeMode;

  const _CalendarPickerDialog({
    this.initialStart,
    this.initialEnd,
    required this.bookedRanges,
    required this.rangeMode,
  });

  @override
  State<_CalendarPickerDialog> createState() => _CalendarPickerDialogState();
}

class _CalendarPickerDialogState extends State<_CalendarPickerDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onDayTapped(DateTime day) {
    if (!widget.rangeMode) {
      Navigator.of(context).pop((day, null));
      return;
    }
    final (start, end) = DateRangeSelection.onDayTapped(
      start: _start,
      end: _end,
      day: day,
      bookedRanges: widget.bookedRanges,
    );
    setState(() {
      _start = start;
      _end = end;
    });
    if (_start != null && _end != null) {
      Navigator.of(context).pop((_start, _end));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.rangeMode ? 'Select dates' : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.close, size: 18, color: themeTaupe),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AvailabilityCalendar(
              bookedRanges: widget.bookedRanges,
              selectionStart: _start,
              selectionEnd: _end,
              onDayTapped: _onDayTapped,
              showLegend: widget.bookedRanges.isNotEmpty,
            ),
            if (_start != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop((null, null)),
                  child: const Text('Clear'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
