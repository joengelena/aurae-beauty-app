import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/pagination.dart';

/// One row of GET /dresses, shaped like the map at the end of
/// getPublicDresses() in shine_api's dressRepository.ts.
const _feedRowJson = r'''
{
  "id": 42,
  "userIdFk": "5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a",
  "name": "Rosa Wrap Midi",
  "brand": "Zimmermann",
  "style": "Wrap",
  "dressType": "Midi",
  "size": "8",
  "color": "Sage",
  "condition": "Excellent",
  "listingType": "rent",
  "isPublic": true,
  "dressPhotoUrl": "https://cdn.example.com/dresses/42/1.jpg",
  "rentalPricePerDay": 85,
  "createdAt": "2026-07-28T03:15:00.000Z",
  "location": "Christchurch City",
  "availableSizes": ["8", "10", "12"]
}
''';

/// GET /dresses/:id — mapDressDbToObject plus location and imageUrls
/// (getPublicDressById in dressRepository.ts).
const _detailJson = r'''
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
  "purchasePrice": null,
  "rentalPricePerDay": 85,
  "availableFrom": "2026-10-01",
  "condition": "Excellent",
  "dressPhotoUrls": [
    "https://cdn.example.com/dresses/42/1.jpg",
    "https://cdn.example.com/dresses/42/2.jpg"
  ],
  "blockedDateRanges": [],
  "notes": "Dry clean only",
  "unresolvedDamageCount": 0,
  "pendingBookingCount": 1,
  "createdAt": "2026-07-28T03:15:00.000Z",
  "updatedAt": "2026-09-30T21:40:12.345Z",
  "location": "Christchurch City",
  "imageUrls": [
    "https://cdn.example.com/dresses/42/1.jpg",
    "https://cdn.example.com/dresses/42/2.jpg"
  ]
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('Listing.fromJson — Browse feed row', () {
    test('parses the fields the tile shows', () {
      final listing = Listing.fromJson(_decode(_feedRowJson));
      expect(listing.id, 42);
      expect(listing.userIdFk, '5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a');
      expect(listing.name, 'Rosa Wrap Midi');
      expect(listing.brand, 'Zimmermann');
      expect(listing.style, 'Wrap');
      expect(listing.size, '8');
      expect(listing.color, 'Sage');
      expect(listing.dressType, 'Midi');
      expect(listing.condition, 'Excellent');
      expect(listing.location, 'Christchurch City');
      expect(listing.listingType, 'rent');
    });

    test('reads the price from rentalPricePerDay as whole dollars', () {
      final listing = Listing.fromJson(_decode(_feedRowJson));
      expect(listing.pricePerDay, isA<int>());
      expect(listing.pricePerDay, 85);
    });

    test('uses the cover photo as the preview image', () {
      final listing = Listing.fromJson(_decode(_feedRowJson));
      expect(listing.previewImgUrl, 'https://cdn.example.com/dresses/42/1.jpg');
    });

    test('takes the upload date from createdAt', () {
      final listing = Listing.fromJson(_decode(_feedRowJson));
      expect(listing.uploadDate.toUtc(), DateTime.utc(2026, 7, 28, 3, 15));
    });

    test('keeps every size the dress group comes in', () {
      final listing = Listing.fromJson(_decode(_feedRowJson));
      expect(listing.availableSizes, ['8', '10', '12']);
    });

    test('a single-size dress without availableSizes lists its own size', () {
      final json = _decode(_feedRowJson)..remove('availableSizes');
      expect(Listing.fromJson(json).availableSizes, ['8']);
    });

    test('tolerates the nullable columns being null', () {
      final json = _decode(_feedRowJson)
        ..['name'] = null
        ..['dressType'] = null
        ..['color'] = null
        ..['dressPhotoUrl'] = null
        ..['rentalPricePerDay'] = null;
      final listing = Listing.fromJson(json);
      expect(listing.name, isNull);
      expect(listing.dressType, isNull);
      expect(listing.color, isNull);
      expect(listing.previewImgUrl, isEmpty);
      expect(listing.pricePerDay, isA<int>());
    });
  });

  group('Listing.fromJsonString — public dress detail', () {
    test('parses the detail payload', () {
      final listing = Listing.fromJsonString(_detailJson);
      expect(listing.id, 42);
      expect(listing.pricePerDay, 85);
      expect(listing.imageUrls, hasLength(2));
      expect(listing.description, 'Dry clean only');
      expect(listing.fitNote, 'Runs small');
      expect(listing.recommendedSizes, ['6', '8']);
      expect(listing.purchasePrice, isNull);
      expect(listing.location, 'Christchurch City');
    });

    test('availableFrom parses to its calendar day', () {
      final from = Listing.fromJsonString(_detailJson).availableFrom!;
      expect([from.year, from.month, from.day], [2026, 10, 1]);
    });

    test('no notes means an empty description, not a crash', () {
      final json = _decode(_detailJson)..['notes'] = null;
      expect(Listing.fromJson(json).description, isEmpty);
    });
  });

  group('PaginatedResponse<Listing>', () {
    test('parses the GET /dresses envelope', () {
      final body = _decode('''
        {
          "data": [$_feedRowJson],
          "totalRows": 23,
          "pageNumber": 1,
          "totalPages": 3
        }
      ''');
      final page = PaginatedResponse<Listing>.fromJson(
        body,
        (json) => Listing.fromJson(json),
      );
      expect(page.data, hasLength(1));
      expect(page.data.single.id, 42);
      expect(page.totalRows, 23);
      expect(page.pageNumber, 1);
      expect(page.totalPages, 3);
    });
  });
}
