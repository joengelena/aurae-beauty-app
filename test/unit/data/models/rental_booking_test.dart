import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/rental_booking.dart';

/// Shaped like mapDressBookingDbToObject in shine_api's
/// rentalBookingRepository: DATE columns as 'YYYY-MM-DD', DECIMAL money run
/// through parseFloat (so a whole amount arrives as a JSON integer).
const _bookingJson = r'''
{
  "id": 311,
  "dressIdFk": 42,
  "bookingType": "rental",
  "bookingDate": "2026-09-20",
  "startDate": "2026-09-26",
  "endDate": "2026-09-28",
  "customerUserIdFk": "9a7e3c1d-2b4f-4e6a-8c0d-1f2e3a4b5c6d",
  "renterName": "Aroha Ngata",
  "renterEmail": "aroha@example.co.nz",
  "renterPhone": "021 555 0199",
  "renterInstagram": "@aroha.wears",
  "totalCost": 170,
  "depositPaid": 50.5,
  "trackingNumber": null,
  "status": "approved",
  "notes": "Picking up after work",
  "createdAt": "2026-09-20T22:10:00.000Z",
  "updatedAt": "2026-09-21T01:00:00.000Z"
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('RentalBooking.fromJson', () {
    test('parses a booking', () {
      final b = RentalBooking.fromJson(_decode(_bookingJson));
      expect(b.id, 311);
      expect(b.dressIdFk, 42);
      expect(b.bookingType, 'rental');
      expect(b.renterName, 'Aroha Ngata');
      expect(b.renterEmail, 'aroha@example.co.nz');
      expect(b.renterPhone, '021 555 0199');
      expect(b.renterInstagram, '@aroha.wears');
      expect(b.status, 'approved');
      expect(b.notes, 'Picking up after work');
    });

    test('wear dates parse to their calendar days', () {
      final b = RentalBooking.fromJson(_decode(_bookingJson));
      expect([b.startDate.year, b.startDate.month, b.startDate.day],
          [2026, 9, 26]);
      expect([b.endDate.year, b.endDate.month, b.endDate.day], [2026, 9, 28]);
      expect([b.bookingDate.year, b.bookingDate.month, b.bookingDate.day],
          [2026, 9, 20]);
    });

    test('money accepts whole and fractional JSON numbers', () {
      final b = RentalBooking.fromJson(_decode(_bookingJson));
      expect(b.totalCost, 170.0);
      expect(b.depositPaid, 50.5);
    });

    test('contact details and deposit may be null', () {
      final json = _decode(_bookingJson)
        ..['renterEmail'] = null
        ..['renterPhone'] = null
        ..['renterInstagram'] = null
        ..['depositPaid'] = null
        ..['notes'] = null
        ..['customerUserIdFk'] = null;
      final b = RentalBooking.fromJson(json);
      expect(b.renterEmail, isNull);
      expect(b.renterPhone, isNull);
      expect(b.renterInstagram, isNull);
      expect(b.depositPaid, isNull);
      expect(b.notes, isNull);
    });

    test('keeps a purchase booking\'s type', () {
      final json = _decode(_bookingJson)..['bookingType'] = 'purchase';
      expect(RentalBooking.fromJson(json).bookingType, 'purchase');
    });
  });

  group('RentalBooking.copyWith', () {
    test('changes only the status', () {
      final b = RentalBooking.fromJson(_decode(_bookingJson));
      final moved = b.copyWith(status: 'ready_for_pickup');
      expect(moved.status, 'ready_for_pickup');
      expect(moved.id, b.id);
      expect(moved.startDate, b.startDate);
      expect(moved.endDate, b.endDate);
      expect(moved.totalCost, b.totalCost);
      expect(moved.renterName, b.renterName);
      expect(b.status, 'approved');
    });
  });
}
