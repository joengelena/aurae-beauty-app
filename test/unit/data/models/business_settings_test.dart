import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/business_settings.dart';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('BusinessSettings.fromJson', () {
    test('parses a boutique\'s settings', () {
      final s = BusinessSettings.fromJson(
          _decode('{"deliveryOption":"both","cleaningBufferDays":2}'));
      expect(s.deliveryOption, 'both');
      expect(s.cleaningBufferDays, 2);
    });

    test('a customer-only account gets pickup and a one-day buffer', () {
      // getBusinessSettings answers {deliveryOption: 'pickup'} when the
      // account has no business; the DB default buffer is one day.
      final s = BusinessSettings.fromJson(_decode('{"deliveryOption":"pickup"}'));
      expect(s.deliveryOption, 'pickup');
      expect(s.cleaningBufferDays, 1);
    });

    test('an empty settings object falls back to the same defaults', () {
      final s = BusinessSettings.fromJson(_decode('{}'));
      expect(s.deliveryOption, 'pickup');
      expect(s.cleaningBufferDays, 1);
    });

    test('explicit nulls fall back to the defaults', () {
      final s = BusinessSettings.fromJson(
          _decode('{"deliveryOption":null,"cleaningBufferDays":null}'));
      expect(s.deliveryOption, 'pickup');
      expect(s.cleaningBufferDays, 1);
    });
  });

  group('BusinessSettings.copyWith / toJson', () {
    test('copyWith changes only what it is given', () {
      const s = BusinessSettings(deliveryOption: 'postal', cleaningBufferDays: 3);
      final changed = s.copyWith(cleaningBufferDays: 2);
      expect(changed.deliveryOption, 'postal');
      expect(changed.cleaningBufferDays, 2);
    });

    test('round-trips through the API\'s key names', () {
      const s = BusinessSettings(deliveryOption: 'both', cleaningBufferDays: 2);
      final back = BusinessSettings.fromJson(s.toJson());
      expect(back.deliveryOption, 'both');
      expect(back.cleaningBufferDays, 2);
    });
  });
}
