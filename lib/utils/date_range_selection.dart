import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/utils/utils.dart';

/// Shared tap-selection logic for rental date-range calendars.
///
/// A rental is a whole day that goes overnight: tapping a single day selects
/// that day plus the next as a one-night stay (e.g. tapping the 23rd selects
/// 23rd-24th). Tapping a later day extends the return date. Tapping the
/// start day again clears the selection. Any other tap restarts a fresh
/// one-night selection at the tapped day.
class DateRangeSelection {
  DateRangeSelection._();

  /// Whether a stay from [start] to [end] touches any unavailable range.
  ///
  /// Both ranges include both of their end days, because that is how the
  /// database compares them (a '[]' daterange): a booking ending on the 9th still has
  /// the dress on the 9th, so a new stay can neither start nor end on it. An
  /// exclusive test here let a selection end on a blocked day, and made a
  /// one-day block invisible altogether.
  static bool conflicts(
    List<BookedRange> bookedRanges,
    DateTime start,
    DateTime end,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return bookedRanges.any((r) {
      if (!r.isUnavailable) return false;
      final rs = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final re = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      return !rs.isAfter(e) && !re.isBefore(s);
    });
  }

  static (DateTime?, DateTime?) _freshStart(
    DateTime day,
    List<BookedRange> bookedRanges,
  ) {
    // The tapped day is itself taken, so no stay can start on it.
    if (conflicts(bookedRanges, day, day)) return (null, null);

    // addDays, not a Duration: this value becomes the booking's end date and is
    // sent to the API. On a daylight-saving change a Duration lands at 23:00 of
    // the same day, which would submit a booking that ends before it starts.
    final next = addDays(day, 1);
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
