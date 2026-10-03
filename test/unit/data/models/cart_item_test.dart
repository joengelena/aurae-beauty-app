import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/cart_item.dart';

/// One line of GET /user/cart (getUserCart + getCart in shine_api): dates
/// rendered as 'YYYY-MM-DD' in SQL, price_per_day an INTEGER, isListed
/// replaced by isAvailable.
Map<String, dynamic> _cartJson({
  String startDate = '2026-10-09',
  String endDate = '2026-10-11',
  int pricePerDay = 85,
}) =>
    jsonDecode('''
{
  "id": 7,
  "dressIdFk": 42,
  "startDate": "$startDate",
  "endDate": "$endDate",
  "pricePerDay": $pricePerDay,
  "createdAt": "2026-09-20T22:10:00.000Z",
  "name": "Rosa Wrap Midi",
  "brand": "Zimmermann",
  "style": "Wrap",
  "size": "8",
  "dressPhotoUrl": "https://cdn.example.com/dresses/42/1.jpg",
  "location": "Christchurch City",
  "isAvailable": true
}
''') as Map<String, dynamic>;

void main() {
  group('CartItem.fromJson', () {
    test('parses a cart line', () {
      final item = CartItem.fromJson(_cartJson());
      expect(item.id, 7);
      expect(item.dressIdFk, 42);
      expect(item.pricePerDay, 85);
      expect(item.name, 'Rosa Wrap Midi');
      expect(item.brand, 'Zimmermann');
      expect(item.style, 'Wrap');
      expect(item.size, '8');
      expect(item.location, 'Christchurch City');
      expect(item.isAvailable, isTrue);
      expect([item.startDate.year, item.startDate.month, item.startDate.day],
          [2026, 10, 9]);
      expect([item.endDate.year, item.endDate.month, item.endDate.day],
          [2026, 10, 11]);
    });

    test('a dress with no public name and no photo still parses', () {
      final json = _cartJson()
        ..['name'] = null
        ..['dressPhotoUrl'] = '';
      final item = CartItem.fromJson(json);
      expect(item.name, isNull);
      expect(item.dressPhotoUrl, isEmpty);
    });

    test('an unavailable line is flagged', () {
      final json = _cartJson()..['isAvailable'] = false;
      expect(CartItem.fromJson(json).isAvailable, isFalse);
    });

    test('a line from an API that does not send isAvailable is available', () {
      final json = _cartJson()..remove('isAvailable');
      expect(CartItem.fromJson(json).isAvailable, isTrue);
    });
  });

  group('CartItem.nights and totalPrice', () {
    test('the 23rd to the 24th is one night', () {
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-10-23', endDate: '2026-10-24'));
      expect(item.nights, 1);
      expect(item.totalPrice, 85);
    });

    test('a weekend is priced per night', () {
      final item = CartItem.fromJson(_cartJson());
      expect(item.nights, 2);
      expect(item.totalPrice, 170);
    });

    test('across NZ spring-forward (27 Sep 2026) nights equal calendar days',
        () {
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-09-26', endDate: '2026-09-28'));
      expect(item.nights, 2);
      expect(item.totalPrice, 170);
    });

    test('a one-night stay on the spring-forward night is still one night',
        () {
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-09-26', endDate: '2026-09-27'));
      expect(item.nights, 1);
    });

    test('across NZ fall-back (5 Apr 2026) nights equal calendar days', () {
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-04-04', endDate: '2026-04-06'));
      expect(item.nights, 2);
    });

    test('a long rental spanning the change is not a night short or long', () {
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-09-20', endDate: '2026-10-04'));
      expect(item.nights, 14);
      expect(item.totalPrice, 14 * 85);
    });

    test('a same-day line is charged one night, as the server charges it', () {
      // postSelfBooking prices max(1, nights), and its comment says this has
      // to match CartItem.nights — the renter reads the price here first.
      final item = CartItem.fromJson(
          _cartJson(startDate: '2026-10-09', endDate: '2026-10-09'));
      expect(item.nights, 1);
      expect(item.totalPrice, 85);
    });
  });
}
