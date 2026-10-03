import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';

/// One row of GET /user/my-bookings (getMyBookings.ts in shine_api).
const _myBookingJson = r'''
{
  "id": 311,
  "dressIdFk": 42,
  "bookingType": "rental",
  "bookingDate": "2026-10-09",
  "startDate": "2026-10-09",
  "endDate": "2026-10-11",
  "customerUserIdFk": "9a7e3c1d-2b4f-4e6a-8c0d-1f2e3a4b5c6d",
  "renterName": "Aroha Ngata",
  "renterEmail": "aroha@example.co.nz",
  "renterPhone": null,
  "renterInstagram": null,
  "totalCost": 170,
  "depositPaid": null,
  "status": "pending",
  "notes": null,
  "createdAt": "2026-09-20T22:10:00.000Z",
  "updatedAt": "2026-09-20T22:10:00.000Z",
  "dressBrand": "Zimmermann",
  "dressStyle": "Wrap",
  "dressPhotoUrl": "https://cdn.example.com/dresses/42/1.jpg",
  "dressInternalName": "Rosa Wrap Midi",
  "dressName": "Rosa Wrap Midi"
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('UpcomingBooking.fromJson', () {
    test('parses a renter booking with its dress summary', () {
      final b = UpcomingBooking.fromJson(_decode(_myBookingJson));
      expect(b.id, 311);
      expect(b.dressIdFk, 42);
      expect(b.bookingType, 'rental');
      expect(b.status, 'pending');
      expect(b.renterName, 'Aroha Ngata');
      expect(b.dressBrand, 'Zimmermann');
      expect(b.dressStyle, 'Wrap');
      expect(b.dressPhotoUrl, 'https://cdn.example.com/dresses/42/1.jpg');
      expect(b.dressInternalName, 'Rosa Wrap Midi');
      expect(b.totalCost, 170.0);
      expect(b.depositPaid, isNull);
      expect(b.notes, isNull);
    });

    test('dates parse to their calendar days', () {
      final b = UpcomingBooking.fromJson(_decode(_myBookingJson));
      expect([b.startDate.year, b.startDate.month, b.startDate.day],
          [2026, 10, 9]);
      expect([b.endDate.year, b.endDate.month, b.endDate.day], [2026, 10, 11]);
    });

    test('a dress without a photo or public name still parses', () {
      final json = _decode(_myBookingJson)
        ..['dressPhotoUrl'] = null
        ..['dressInternalName'] = null
        ..['dressName'] = null;
      final b = UpcomingBooking.fromJson(json);
      expect(b.dressPhotoUrl, isNull);
      expect(b.dressInternalName, isNull);
    });
  });
}
