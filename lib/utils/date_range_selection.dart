import 'package:shine_app/data/models/booked_range.dart';

/// Shared tap-selection logic for rental date-range calendars.
///
/// A rental is a whole day that goes overnight: tapping a single day selects
/// that day plus the next as a one-night stay (e.g. tapping the 23rd selects
/// 23rd-24th). Tapping a later day extends the return date. Tapping the
/// start day again clears the selection. Any other tap restarts a fresh
/// one-night selection at the tapped day.
class DateRangeSelection {
  DateRangeSelection._();

  static bool conflicts(
    List<BookedRange> bookedRanges,
    DateTime start,
    DateTime end,
  ) {
    return bookedRanges.any((r) {
      if (!r.isUnavailable) return false;
      final rs = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final re = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      return rs.isBefore(end) && re.isAfter(start);
    });
  }

  static (DateTime, DateTime?) _freshStart(
    DateTime day,
    List<BookedRange> bookedRanges,
  ) {
    final next = day.add(const Duration(days: 1));
    if (conflicts(bookedRanges, day, next)) return (day, null);
    return (day, next);
  }

  /// Returns the new (start, end) pair for a tap on [day].
  static (DateTime?, DateTime?) onDayTapped({
    required DateTime? start,
    required DateTime? end,
    required DateTime day,
    required List<BookedRange> bookedRanges,
  }) {
    final d = DateTime(day.year, day.month, day.day);

    if (start == null) return _freshStart(d, bookedRanges);

    final s = DateTime(start.year, start.month, start.day);
    if (d == s) return (null, null);

    if (end == null) {
      // The automatic one-night default hit a conflict, so this selection
      // is still awaiting a manually picked return date.
      if (d.isBefore(s)) return _freshStart(d, bookedRanges);
      if (conflicts(bookedRanges, s, d)) return _freshStart(d, bookedRanges);
      return (start, d);
    }

    final e = DateTime(end.year, end.month, end.day);
    if (d.isAfter(e)) {
      if (conflicts(bookedRanges, s, d)) return _freshStart(d, bookedRanges);
      return (start, d);
    }

    return _freshStart(d, bookedRanges);
  }
}
