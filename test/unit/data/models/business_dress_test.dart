import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/business_dress.dart';

/// Shaped exactly like mapDressDbToObject in
/// shine_api/src/app/repositories/dressRepository/mapDressDbToObject.ts:
/// camelCase keys, DATE columns as 'YYYY-MM-DD', TIMESTAMPs as ISO instants,
/// blocked_date_ranges as the raw JSONB list of {startDate, endDate}.
const _ownerDressJson = r'''
{
  "id": 42,
  "userIdFk": "5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a",
  "name": "Rosa Wrap Midi",
  "brand": "Zimmermann",
  "style": "Wrap",
  "dressType": "Midi",
  "listingType": "rent",
  "status": "active",
  "isPublic": true,
  "purchaseYear": 2024,
  "internalName": "Rosa #2",
  "color": "Sage",
  "rentalCount": 3,
  "size": "8",
  "fitNote": "Runs small",
  "recommendedSizes": ["6", "8"],
  "purchasePrice": 650,
  "rentalPricePerDay": 85,
  "availableFrom": "2026-10-01",
  "condition": "Excellent",
  "dressPhotoUrls": [
    "https://cdn.example.com/dresses/42/1.jpg",
    "https://cdn.example.com/dresses/42/2.jpg"
  ],
  "blockedDateRanges": [
    {"startDate": "2026-10-10", "endDate": "2026-10-12"},
    {"startDate": "2026-12-24", "endDate": "2026-12-26"}
  ],
  "notes": "Dry clean only",
  "unresolvedDamageCount": 1,
  "pendingBookingCount": 2,
  "createdAt": "2026-07-28T03:15:00.000Z",
  "updatedAt": "2026-09-30T21:40:12.345Z"
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('BusinessDress.fromJson', () {
    test('parses a full owner dress', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));

      expect(dress.id, 42);
      expect(dress.userIdFk, '5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a');
      expect(dress.name, 'Rosa Wrap Midi');
      expect(dress.brand, 'Zimmermann');
      expect(dress.style, 'Wrap');
      expect(dress.dressType, 'Midi');
      expect(dress.listingType, 'rent');
      expect(dress.status, 'active');
      expect(dress.isPublic, isTrue);
      expect(dress.purchaseYear, 2024);
      expect(dress.internalName, 'Rosa #2');
      expect(dress.color, 'Sage');
      expect(dress.rentalCount, 3);
      expect(dress.size, '8');
      expect(dress.fitNote, 'Runs small');
      expect(dress.recommendedSizes, ['6', '8']);
      expect(dress.condition, 'Excellent');
      expect(dress.notes, 'Dry clean only');
      expect(dress.unresolvedDamageCount, 1);
      expect(dress.pendingBookingCount, 2);
    });

    test('prices are whole dollars', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));
      expect(dress.rentalPricePerDay, isA<int>());
      expect(dress.rentalPricePerDay, 85);
      expect(dress.purchasePrice, 650);
    });

    test('a DATE parses to that calendar day', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));
      final from = dress.availableFrom!;
      expect([from.year, from.month, from.day], [2026, 10, 1]);
    });

    test('timestamps parse to the right instant', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));
      expect(dress.createdAt.toUtc(), DateTime.utc(2026, 7, 28, 3, 15));
      expect(dress.updatedAt.toUtc(),
          DateTime.utc(2026, 9, 30, 21, 40, 12, 345));
    });

    test('blocked ranges keep both end days', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));
      expect(dress.blockedDateRanges, hasLength(2));
      final first = dress.blockedDateRanges.first;
      expect([first.start.year, first.start.month, first.start.day],
          [2026, 10, 10]);
      expect([first.end.year, first.end.month, first.end.day], [2026, 10, 12]);
    });

    test('photos keep their order and the first is the cover', () {
      final dress = BusinessDress.fromJson(_decode(_ownerDressJson));
      expect(dress.dressPhotoUrls, hasLength(2));
      expect(dress.dressPhotoUrl, 'https://cdn.example.com/dresses/42/1.jpg');
    });

    test('nullable columns sent as null parse without throwing', () {
      final json = _decode(_ownerDressJson)
        ..['name'] = null
        ..['dressType'] = null
        ..['purchaseYear'] = null
        ..['internalName'] = null
        ..['color'] = null
        ..['rentalCount'] = null
        ..['fitNote'] = null
        ..['purchasePrice'] = null
        ..['rentalPricePerDay'] = null
        ..['availableFrom'] = null
        ..['notes'] = null;
      final dress = BusinessDress.fromJson(json);
      expect(dress.name, isNull);
      expect(dress.dressType, isNull);
      expect(dress.purchaseYear, isNull);
      expect(dress.internalName, isNull);
      expect(dress.color, isNull);
      expect(dress.fitNote, isNull);
      expect(dress.purchasePrice, isNull);
      expect(dress.rentalPricePerDay, isNull);
      expect(dress.availableFrom, isNull);
      expect(dress.notes, isNull);
    });

    test('optional keys missing altogether fall back to defaults', () {
      final dress = BusinessDress.fromJson(_decode(r'''
        {
          "id": 7,
          "userIdFk": "5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a",
          "brand": "Shona Joy",
          "style": "Halter",
          "size": "10",
          "condition": "Good",
          "createdAt": "2026-07-28T03:15:00.000Z",
          "updatedAt": "2026-07-28T03:15:00.000Z"
        }
      '''));
      expect(dress.status, 'active');
      expect(dress.listingType, 'rent');
      expect(dress.isPublic, isFalse);
      expect(dress.dressPhotoUrls, isEmpty);
      expect(dress.dressPhotoUrl, isNull);
      expect(dress.blockedDateRanges, isEmpty);
      expect(dress.recommendedSizes, isEmpty);
      expect(dress.unresolvedDamageCount, 0);
      expect(dress.pendingBookingCount, 0);
    });

    test('a sold dress keeps its status', () {
      final json = _decode(_ownerDressJson)..['status'] = 'sold';
      expect(BusinessDress.fromJson(json).status, 'sold');
    });
  });
}
