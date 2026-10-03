import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/utils/booking_status.dart';

/// The legal moves out of each status, copied from
/// dress_bookings_enforce_transition() in
/// postgresql-db-tool/sql/shine/init/99_triggers.sql.
///
/// The database is the authority. Anything the app offers as a next step must
/// be in here, or the owner taps a button and gets a 409.
const Map<String, Set<String>> _rentalTransitions = {
  'pending': {'approved', 'declined', 'cancelled_by_customer'},
  'approved': {
    'ready_for_pickup',
    'ready_to_ship',
    'cancelled_by_owner',
    'cancelled_by_customer',
  },
  'ready_for_pickup': {
    'collected',
    'cancelled_by_owner',
    'cancelled_by_customer',
  },
  'ready_to_ship': {'shipped', 'cancelled_by_owner', 'cancelled_by_customer'},
  'collected': {'returned'},
  'shipped': {'returned'},
  'returned': {'inspected'},
  'inspected': {'completed', 'completed_with_damage'},
};

const Map<String, Set<String>> _purchaseTransitions = {
  'pending': {'approved', 'declined', 'cancelled_by_customer'},
  'approved': {
    'ready_for_pickup',
    'ready_to_ship',
    'cancelled_by_owner',
    'cancelled_by_customer',
  },
  'ready_for_pickup': {
    'collected',
    'cancelled_by_owner',
    'cancelled_by_customer',
  },
  'ready_to_ship': {'shipped', 'cancelled_by_owner', 'cancelled_by_customer'},
  'collected': {'completed'},
  'shipped': {'completed'},
};

/// Every value the dress_bookings.status CHECK constraint allows.
const List<String> _allStatuses = [
  'pending',
  'approved',
  'declined',
  'cancelled_by_customer',
  'cancelled_by_owner',
  'ready_for_pickup',
  'ready_to_ship',
  'collected',
  'shipped',
  'returned',
  'inspected',
  'completed',
  'completed_with_damage',
];

/// Statuses with no way out in the rental table.
const List<String> _terminalStatuses = [
  'declined',
  'cancelled_by_customer',
  'cancelled_by_owner',
  'completed',
  'completed_with_damage',
];

void main() {
  group('BookingStatus.nextStatus — rental', () {
    test('walks the full rental cycle: out, back, inspected, closed', () {
      expect(BookingStatus.nextStatus('pending'), 'approved');
      expect(BookingStatus.nextStatus('approved'), 'ready_for_pickup');
      expect(BookingStatus.nextStatus('ready_for_pickup'), 'collected');
      expect(BookingStatus.nextStatus('collected'), 'returned');
      expect(BookingStatus.nextStatus('shipped'), 'returned');
      expect(BookingStatus.nextStatus('returned'), 'inspected');
      expect(BookingStatus.nextStatus('inspected'), 'completed');
    });

    test('bookingType defaults to rental', () {
      expect(
        BookingStatus.nextStatus('collected'),
        BookingStatus.nextStatus('collected', bookingType: 'rental'),
      );
    });

    test('every offered next step is a transition the database accepts', () {
      for (final status in _allStatuses) {
        final next = BookingStatus.nextStatus(status, bookingType: 'rental');
        if (next == null) continue;
        expect(
          _rentalTransitions[status] ?? const <String>{},
          contains(next),
          reason: 'rental $status -> $next is rejected by the DB trigger',
        );
      }
    });

    test('terminal statuses have no next step and no button', () {
      for (final status in _terminalStatuses) {
        expect(BookingStatus.nextStatus(status), isNull, reason: status);
        expect(BookingStatus.nextLabel(status), isNull, reason: status);
      }
    });

    test('event, photoshoot and other bookings follow the rental cycle', () {
      // The trigger's ELSE branch treats every non-purchase type as a rental.
      for (final type in ['event', 'photoshoot', 'other']) {
        expect(BookingStatus.nextStatus('collected', bookingType: type),
            'returned',
            reason: type);
        expect(BookingStatus.nextStatus('returned', bookingType: type),
            'inspected',
            reason: type);
      }
    });

    test('ready_to_ship never offers anything but shipped', () {
      // Shipping needs a tracking number, so the app may choose not to offer
      // a one-tap step here; if it does, it has to be the only legal one.
      final next = BookingStatus.nextStatus('ready_to_ship');
      expect(next == null || next == 'shipped', isTrue, reason: '$next');
    });
  });

  group('BookingStatus.nextStatus — purchase', () {
    test('closes at handover', () {
      expect(BookingStatus.nextStatus('pending', bookingType: 'purchase'),
          'approved');
      expect(BookingStatus.nextStatus('approved', bookingType: 'purchase'),
          'ready_for_pickup');
      expect(
          BookingStatus.nextStatus('ready_for_pickup', bookingType: 'purchase'),
          'collected');
      expect(BookingStatus.nextStatus('collected', bookingType: 'purchase'),
          'completed');
      expect(BookingStatus.nextStatus('shipped', bookingType: 'purchase'),
          'completed');
    });

    test('never offers returned or inspected — nothing comes back', () {
      for (final status in _allStatuses) {
        final next = BookingStatus.nextStatus(status, bookingType: 'purchase');
        expect(next, isNot('returned'), reason: status);
        expect(next, isNot('inspected'), reason: status);
      }
    });

    test('every offered next step is a transition the database accepts', () {
      for (final status in _allStatuses) {
        final next = BookingStatus.nextStatus(status, bookingType: 'purchase');
        if (next == null) continue;
        expect(
          _purchaseTransitions[status] ?? const <String>{},
          contains(next),
          reason: 'purchase $status -> $next is rejected by the DB trigger',
        );
      }
    });

    test('the handover button does not talk about a return', () {
      final label =
          BookingStatus.nextLabel('collected', bookingType: 'purchase');
      expect(label, isNotNull);
      expect(label!.toLowerCase(), isNot(contains('return')));
    });

    test('terminal statuses have no next step', () {
      for (final status in _terminalStatuses) {
        expect(BookingStatus.nextStatus(status, bookingType: 'purchase'),
            isNull,
            reason: status);
      }
    });
  });

  group('BookingStatus.nextLabel', () {
    test('a label is shown exactly when there is a next step', () {
      for (final type in ['rental', 'purchase']) {
        for (final status in _allStatuses) {
          final next = BookingStatus.nextStatus(status, bookingType: type);
          final label = BookingStatus.nextLabel(status, bookingType: type);
          expect(label == null, next == null, reason: '$type $status');
          if (label != null) expect(label.trim(), isNotEmpty);
        }
      }
    });
  });

  group('BookingStatus owner cancellation', () {
    bool dbLetsOwnerCallOff(Map<String, Set<String>> table, String status) {
      final allowed = table[status] ?? const <String>{};
      // A request is declined; anything already agreed to is cancelled.
      return status == 'pending'
          ? allowed.contains('declined')
          : allowed.contains('cancelled_by_owner');
    }

    test('matches the transition table for rentals and purchases', () {
      for (final status in _allStatuses) {
        expect(BookingStatus.ownerCanCancel(status),
            dbLetsOwnerCallOff(_rentalTransitions, status),
            reason: 'rental $status');
        expect(BookingStatus.ownerCanCancel(status),
            dbLetsOwnerCallOff(_purchaseTransitions, status),
            reason: 'purchase $status');
      }
    });

    test('the cancel status sent is one the database accepts', () {
      for (final status in _allStatuses) {
        if (!BookingStatus.ownerCanCancel(status)) continue;
        final target = BookingStatus.ownerCancelStatus(status);
        expect(_rentalTransitions[status], contains(target), reason: status);
        expect(_purchaseTransitions[status], contains(target), reason: status);
      }
    });

    test('a pending request is declined, an agreed booking is cancelled', () {
      expect(BookingStatus.ownerCancelStatus('pending'), 'declined');
      expect(BookingStatus.ownerCancelStatus('approved'), 'cancelled_by_owner');
      expect(BookingStatus.ownerCancelStatus('ready_for_pickup'),
          'cancelled_by_owner');
      expect(BookingStatus.ownerCancelLabel('pending'),
          isNot(BookingStatus.ownerCancelLabel('approved')));
    });

    test('once the dress has changed hands it cannot be cancelled', () {
      for (final status in [
        'collected',
        'shipped',
        'returned',
        'inspected',
        'completed',
        'completed_with_damage',
        'declined',
        'cancelled_by_customer',
        'cancelled_by_owner',
      ]) {
        expect(BookingStatus.ownerCanCancel(status), isFalse, reason: status);
      }
    });
  });

  group('BookingStatus date holding, revenue and closure', () {
    test('only declined and cancelled bookings release their dates', () {
      // Mirrors booking_holds_dates() in DressBookings.sql.
      const released = {'declined', 'cancelled_by_customer', 'cancelled_by_owner'};
      for (final status in _allStatuses) {
        expect(BookingStatus.holdsDates(status), !released.contains(status),
            reason: status);
      }
    });

    test('a manual blackout range ("blocked") holds its dates', () {
      expect(BookingStatus.holdsDates('blocked'), isTrue);
    });

    test('revenue counts agreed bookings, not requests or cancellations', () {
      expect(BookingStatus.countsAsRevenue('pending'), isFalse);
      expect(BookingStatus.countsAsRevenue('declined'), isFalse);
      expect(BookingStatus.countsAsRevenue('cancelled_by_customer'), isFalse);
      expect(BookingStatus.countsAsRevenue('cancelled_by_owner'), isFalse);
      for (final status in [
        'approved',
        'ready_for_pickup',
        'ready_to_ship',
        'collected',
        'shipped',
        'returned',
        'inspected',
        'completed',
        'completed_with_damage',
      ]) {
        expect(BookingStatus.countsAsRevenue(status), isTrue, reason: status);
      }
    });

    test('closed means the database allows no further move', () {
      for (final status in _allStatuses) {
        final dbTerminal = !_rentalTransitions.containsKey(status);
        expect(BookingStatus.isClosed(status), dbTerminal, reason: status);
        expect(BookingStatus.isOpen(status), !dbTerminal, reason: status);
      }
    });

    test('every status has a human label; unknown ones fall back to raw', () {
      for (final status in _allStatuses) {
        final label = BookingStatus.label(status);
        expect(label, isNotEmpty);
        expect(label, isNot(status), reason: 'raw snake_case shown for $status');
      }
      expect(BookingStatus.label('something_new'), 'something_new');
    });
  });

  group('BookingStatus.isOverdue (date-only)', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final lastWeek = DateTime(now.year, now.month, now.day - 7);

    test('a dress due back today is not overdue', () {
      expect(BookingStatus.isOverdue('collected', today), isFalse);
      expect(
        BookingStatus.isOverdue(
            'collected', DateTime(today.year, today.month, today.day, 23, 59)),
        isFalse,
      );
    });

    test('a dress due back yesterday and still out is overdue', () {
      expect(BookingStatus.isOverdue('collected', yesterday), isTrue);
      expect(BookingStatus.isOverdue('shipped', yesterday), isTrue);
    });

    test('time of day on the due date is ignored', () {
      final lateYesterday = DateTime(
          yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      expect(BookingStatus.isOverdue('collected', lateYesterday), isTrue);
    });

    test('a dress due back tomorrow is not overdue', () {
      expect(BookingStatus.isOverdue('collected', tomorrow), isFalse);
    });

    test('a booking that never went out is not overdue', () {
      for (final status in [
        'pending',
        'approved',
        'ready_for_pickup',
        'ready_to_ship',
      ]) {
        expect(BookingStatus.isOverdue(status, lastWeek), isFalse,
            reason: status);
      }
    });

    test('a dress already back is not overdue', () {
      for (final status in [
        'returned',
        'inspected',
        'completed',
        'completed_with_damage',
        'cancelled_by_owner',
      ]) {
        expect(BookingStatus.isOverdue(status, lastWeek), isFalse,
            reason: status);
      }
    });
  });
}
