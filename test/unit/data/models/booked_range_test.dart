import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/booked_range.dart';

void main() {
  group('BookedRange.fromJson', () {
    // GET /dresses/:id/bookings returns booking ranges, cleaning-buffer
    // ranges and manual blocks, all as {startDate, endDate, status}.
    test('parses a booking range to its calendar days', () {
      final r = BookedRange.fromJson(<String, dynamic>{
        'startDate': '2026-10-10',
        'endDate': '2026-10-12',
        'status': 'approved',
      });
      expect([r.startDate.year, r.startDate.month, r.startDate.day],
          [2026, 10, 10]);
      expect([r.endDate.year, r.endDate.month, r.endDate.day], [2026, 10, 12]);
      expect(r.status, 'approved');
      expect(r.isUnavailable, isTrue);
    });

    test('cleaning buffers and manual blocks ("blocked") are unavailable', () {
      final r = BookedRange.fromJson(<String, dynamic>{
        'startDate': '2026-10-13',
        'endDate': '2026-10-13',
        'status': 'blocked',
      });
      expect(r.isUnavailable, isTrue);
    });

    test('a range with no status is treated as taken', () {
      final r = BookedRange.fromJson(<String, dynamic>{
        'startDate': '2026-10-13',
        'endDate': '2026-10-14',
      });
      expect(r.isUnavailable, isTrue);
    });

    test('declined and cancelled bookings do not block', () {
      for (final status in [
        'declined',
        'cancelled_by_customer',
        'cancelled_by_owner',
      ]) {
        final r = BookedRange.fromJson(<String, dynamic>{
          'startDate': '2026-10-10',
          'endDate': '2026-10-12',
          'status': status,
        });
        expect(r.isUnavailable, isFalse, reason: status);
      }
    });
  });
}
