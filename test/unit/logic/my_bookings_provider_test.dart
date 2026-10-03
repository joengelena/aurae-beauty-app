import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/logic/my_bookings_provider.dart';

UpcomingBooking _booking(String status) => UpcomingBooking.fromJson(
      <String, dynamic>{
        'id': 311,
        'dressIdFk': 42,
        'bookingType': 'rental',
        'bookingDate': '2026-10-09',
        'startDate': '2026-10-09',
        'endDate': '2026-10-11',
        'renterName': 'Aroha Ngata',
        'renterEmail': 'aroha@example.co.nz',
        'totalCost': 170,
        'depositPaid': null,
        'status': status,
        'notes': null,
        'dressBrand': 'Zimmermann',
        'dressStyle': 'Wrap',
        'dressPhotoUrl': null,
        'dressInternalName': 'Rosa Wrap Midi',
      },
    );

void main() {
  group('isBookingCancellable (renter self-cancel)', () {
    // cancelMyBooking.ts allows exactly ['pending', 'approved'].
    test('a request or an agreed booking can be cancelled by the renter', () {
      expect(isBookingCancellable(_booking('pending')), isTrue);
      expect(isBookingCancellable(_booking('approved')), isTrue);
    });

    test('once the owner is fulfilling it, the renter cannot cancel', () {
      for (final status in [
        'ready_for_pickup',
        'ready_to_ship',
        'collected',
        'shipped',
        'returned',
        'inspected',
        'completed',
        'completed_with_damage',
      ]) {
        expect(isBookingCancellable(_booking(status)), isFalse,
            reason: status);
      }
    });

    test('an already closed booking cannot be cancelled again', () {
      for (final status in [
        'declined',
        'cancelled_by_customer',
        'cancelled_by_owner',
      ]) {
        expect(isBookingCancellable(_booking(status)), isFalse,
            reason: status);
      }
    });
  });
}
