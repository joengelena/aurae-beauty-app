import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/utils/date_range_selection.dart';

DateTime _d(int month, int day, [int year = 2026]) => DateTime(year, month, day);

BookedRange _range(DateTime start, DateTime end, [String status = 'approved']) =>
    BookedRange(startDate: start, endDate: end, status: status);

(DateTime?, DateTime?) _tap(
  DateTime day, {
  DateTime? start,
  DateTime? end,
  List<BookedRange> ranges = const [],
}) =>
    DateRangeSelection.onDayTapped(
      start: start,
      end: end,
      day: day,
      bookedRanges: ranges,
    );

bool _isMidnight(DateTime d) =>
    d.hour == 0 && d.minute == 0 && d.second == 0 && d.millisecond == 0;

void main() {
  group('DateRangeSelection.conflicts — inclusive ranges', () {
    // Booked 10th to 12th inclusive, as the database's '[]' daterange.
    final booked = [_range(_d(10, 10), _d(10, 12))];

    test('every day of a booked range is taken, both ends included', () {
      for (final day in [10, 11, 12]) {
        expect(
            DateRangeSelection.conflicts(booked, _d(10, day), _d(10, day)),
            isTrue,
            reason: 'Oct $day');
      }
    });

    test('a stay cannot end on the first booked day', () {
      expect(DateRangeSelection.conflicts(booked, _d(10, 8), _d(10, 10)),
          isTrue);
    });

    test('a stay cannot start on the last booked day', () {
      expect(DateRangeSelection.conflicts(booked, _d(10, 12), _d(10, 14)),
          isTrue);
    });

    test('a stay that spans the whole booking conflicts', () {
      expect(DateRangeSelection.conflicts(booked, _d(10, 5), _d(10, 20)),
          isTrue);
    });

    test('stays entirely before or after are free', () {
      expect(DateRangeSelection.conflicts(booked, _d(10, 7), _d(10, 9)),
          isFalse);
      expect(DateRangeSelection.conflicts(booked, _d(10, 13), _d(10, 15)),
          isFalse);
    });

    test('a one-day block is not invisible', () {
      final oneDay = [_range(_d(10, 10), _d(10, 10), 'blocked')];
      expect(DateRangeSelection.conflicts(oneDay, _d(10, 10), _d(10, 10)),
          isTrue);
      expect(DateRangeSelection.conflicts(oneDay, _d(10, 9), _d(10, 11)),
          isTrue);
      expect(DateRangeSelection.conflicts(oneDay, _d(10, 9), _d(10, 10)),
          isTrue);
    });

    test('declined and cancelled bookings free their dates', () {
      for (final status in [
        'declined',
        'cancelled_by_customer',
        'cancelled_by_owner',
      ]) {
        final ranges = [_range(_d(10, 10), _d(10, 12), status)];
        expect(DateRangeSelection.conflicts(ranges, _d(10, 10), _d(10, 12)),
            isFalse,
            reason: status);
      }
    });

    test('pending requests and manual blocks hold their dates', () {
      for (final status in ['pending', 'approved', 'collected', 'blocked']) {
        final ranges = [_range(_d(10, 10), _d(10, 12), status)];
        expect(DateRangeSelection.conflicts(ranges, _d(10, 11), _d(10, 11)),
            isTrue,
            reason: status);
      }
    });

    test('time of day is ignored on both sides', () {
      final ranges = [_range(_d(10, 10), DateTime(2026, 10, 12, 0, 0))];
      expect(
        DateRangeSelection.conflicts(
            ranges, DateTime(2026, 10, 12, 15, 30), DateTime(2026, 10, 13, 9)),
        isTrue,
      );
    });

    test('nothing booked means nothing conflicts', () {
      expect(DateRangeSelection.conflicts(const [], _d(10, 1), _d(10, 30)),
          isFalse);
    });
  });

  group('DateRangeSelection.onDayTapped', () {
    test('a single tap selects that day plus the next as one night', () {
      final (start, end) = _tap(_d(10, 5));
      expect(start, _d(10, 5));
      expect(end, _d(10, 6));
    });

    test('tapping a booked day does not start a selection', () {
      final ranges = [_range(_d(10, 10), _d(10, 12))];
      final (start, end) = _tap(_d(10, 11), ranges: ranges);
      expect(start, isNull);
      expect(end, isNull);
    });

    test('tapping a manually blocked day does not start a selection', () {
      final ranges = [_range(_d(10, 10), _d(10, 10), 'blocked')];
      final (start, end) = _tap(_d(10, 10), ranges: ranges);
      expect(start, isNull);
      expect(end, isNull);
    });

    test('tapping the start day again clears the selection', () {
      final (start, end) = _tap(_d(10, 5), start: _d(10, 5), end: _d(10, 6));
      expect(start, isNull);
      expect(end, isNull);
    });

    test('tapping a later free day extends the return date', () {
      final (start, end) = _tap(_d(10, 9), start: _d(10, 5), end: _d(10, 6));
      expect(start, _d(10, 5));
      expect(end, _d(10, 9));
    });

    test('cannot extend across a booked day — starts afresh instead', () {
      final ranges = [_range(_d(10, 7), _d(10, 7))];
      final (start, end) =
          _tap(_d(10, 9), start: _d(10, 5), end: _d(10, 6), ranges: ranges);
      expect(start, _d(10, 9));
      expect(end, _d(10, 10));
    });

    test('tapping before the start starts a new one-night selection', () {
      final (start, end) = _tap(_d(10, 3), start: _d(10, 5), end: _d(10, 6));
      expect(start, _d(10, 3));
      expect(end, _d(10, 4));
    });

    test('a tapped day carrying a time or UTC flag is treated as that day',
        () {
      final (start, end) = _tap(DateTime.utc(2026, 10, 5));
      expect(start, _d(10, 5));
      expect(end, _d(10, 6));
    });

    test('one-night default across spring-forward ends at next midnight', () {
      // NZ clocks go forward on Sunday 27 Sep 2026.
      for (final day in [26, 27]) {
        final (start, end) = _tap(_d(9, day));
        expect(start, _d(9, day));
        expect(end, isNotNull);
        final e = end!;
        expect([e.year, e.month, e.day], [2026, 9, day + 1]);
        expect(_isMidnight(e), isTrue, reason: '$e');
      }
    });

    test('one-night default across fall-back ends at next midnight', () {
      // NZ clocks go back on Sunday 5 Apr 2026.
      for (final day in [4, 5]) {
        final (start, end) = _tap(_d(4, day));
        expect(start, _d(4, day));
        expect(end, isNotNull);
        final e = end!;
        expect([e.year, e.month, e.day], [2026, 4, day + 1]);
        expect(_isMidnight(e), isTrue, reason: '$e');
      }
    });

    test('any sequence of taps leaves a valid selection', () {
      // A sweep over every pair and triple of taps in a three-week window,
      // with a two-day booking, a one-day manual block, and a declined
      // booking that must not count.
      final ranges = [
        _range(_d(10, 7), _d(10, 8)),
        _range(_d(10, 14), _d(10, 14), 'blocked'),
        _range(_d(10, 3), _d(10, 4), 'declined'),
      ];
      final days = [for (var i = 1; i <= 21; i++) _d(10, i)];

      void check((DateTime?, DateTime?) selection, String path) {
        final (start, end) = selection;
        if (start == null) {
          expect(end, isNull, reason: 'end without start after $path');
          return;
        }
        expect(_isMidnight(start), isTrue, reason: path);
        expect(DateRangeSelection.conflicts(ranges, start, start), isFalse,
            reason: 'selection starts on a taken day after $path');
        if (end != null) {
          expect(_isMidnight(end), isTrue, reason: path);
          expect(start.isBefore(end), isTrue,
              reason: 'start not before end after $path');
          expect(DateRangeSelection.conflicts(ranges, start, end), isFalse,
              reason: 'selection spans a taken day after $path');
        }
      }

      for (final a in days) {
        final first = _tap(a, ranges: ranges);
        check(first, '${a.day}');
        for (final b in days) {
          final second =
              _tap(b, start: first.$1, end: first.$2, ranges: ranges);
          check(second, '${a.day},${b.day}');
          for (final c in days) {
            final third =
                _tap(c, start: second.$1, end: second.$2, ranges: ranges);
            check(third, '${a.day},${b.day},${c.day}');
          }
        }
      }
    });
  });
}
