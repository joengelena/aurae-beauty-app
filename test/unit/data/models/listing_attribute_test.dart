import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/listing_attribute.dart';

void main() {
  group('ListingAttribute.fromJson', () {
    // dress_attribute.attribute_values is a TEXT column holding a JSON array,
    // and mapDressAttributesDbToObject passes it through as that string.
    test('decodes the JSON-encoded value list', () {
      final a = ListingAttribute.fromJson(<String, dynamic>{
        'name': 'brand',
        'attributeValues': '["Alex Perry", "Shona Joy", "Zimmermann"]',
      });
      expect(a.name, 'brand');
      expect(a.attributeValues, ['Alex Perry', 'Shona Joy', 'Zimmermann']);
    });

    test('keeps apostrophes and spaces in values', () {
      final a = ListingAttribute.fromJson(<String, dynamic>{
        'name': 'location',
        'attributeValues': '["Hawke\'s Bay", "Timaru - Oamaru"]',
      });
      expect(a.attributeValues, ["Hawke's Bay", 'Timaru - Oamaru']);
    });

    test('the value list can take an "Any" option at the front', () {
      // FilteringProvider inserts 'Any' into this list after loading it.
      final a = ListingAttribute.fromJson(<String, dynamic>{
        'name': 'size',
        'attributeValues': '["XS", "S"]',
      });
      a.attributeValues.insert(0, 'Any');
      expect(a.attributeValues, ['Any', 'XS', 'S']);
    });

    test('fromJsonString parses a whole attribute', () {
      final a = ListingAttribute.fromJsonString(
          '{"name":"dress_type","attributeValues":"[\\"Midi\\",\\"Maxi\\"]"}');
      expect(a.name, 'dress_type');
      expect(a.attributeValues, ['Midi', 'Maxi']);
    });
  });
}
