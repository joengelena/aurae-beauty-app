import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/utils/filter_utils.dart';

/// Query parameters GET /dresses actually reads
/// (shine_api/src/app/controllers/dressController/getPublicDresses.ts).
const Set<String> _apiQueryKeys = {
  'limit',
  'pageNumber',
  'userId',
  'startDate',
  'endDate',
  'q',
  'sortBy',
  'brand',
  'style',
  'dressType',
  'size',
  'color',
  'condition',
  'location',
  'priceFrom',
  'priceTo',
  'ungrouped',
};

/// Attribute names seeded into dress_attribute
/// (postgresql-db-tool/sql/shine/base-seed/02_dress_attributes.sql). The
/// filter UI keys its dropdowns by these names.
const List<String> _seededAttributeNames = [
  'brand',
  'style',
  'size',
  'color',
  'condition',
  'dress_type',
  'location',
];

void main() {
  group('FilterUtils.toApiQueryParams', () {
    test('every seeded filter attribute reaches the API', () {
      for (final name in _seededAttributeNames) {
        final params = FilterUtils.toApiQueryParams({name: 'X'});
        expect(params, hasLength(1), reason: '$name was dropped');
        expect(_apiQueryKeys, contains(params.keys.single), reason: name);
        expect(params.values.single, 'X');
      }
    });

    test('dress_type is sent as dressType', () {
      expect(FilterUtils.toApiQueryParams({'dress_type': 'Midi'}),
          {'dressType': 'Midi'});
    });

    test('price range goes out as priceFrom and priceTo', () {
      expect(
        FilterUtils.toApiQueryParams({'priceFrom': '50', 'priceTo': '150'}),
        {'priceFrom': '50', 'priceTo': '150'},
      );
    });

    test('date range goes out as startDate and endDate', () {
      expect(
        FilterUtils.toApiQueryParams(
            {'startDate': '2026-10-10', 'endDate': '2026-10-12'}),
        {'startDate': '2026-10-10', 'endDate': '2026-10-12'},
      );
    });

    test('"Any" and empty values mean no filter', () {
      expect(
        FilterUtils.toApiQueryParams({
          'brand': 'Any',
          'size': '',
          'priceFrom': '',
          'priceTo': 'Any',
          'color': 'Sage',
        }),
        {'color': 'Sage'},
      );
    });

    test('only emits keys the API reads, never snake_case', () {
      final params = FilterUtils.toApiQueryParams({
        for (final name in _seededAttributeNames) name: 'X',
        'priceFrom': '10',
        'priceTo': '20',
        'startDate': '2026-10-10',
        'endDate': '2026-10-12',
        'somethingElse': 'Y',
      });
      for (final key in params.keys) {
        expect(_apiQueryKeys, contains(key));
        expect(key, isNot(contains('_')));
      }
      expect(params, hasLength(_seededAttributeNames.length + 4));
    });

    test('empty input gives an empty query', () {
      expect(FilterUtils.toApiQueryParams({}), isEmpty);
    });
  });

  group('FilterUtils display', () {
    test('every seeded attribute has a display name', () {
      for (final name in _seededAttributeNames) {
        expect(FilterUtils.filterDisplayNames[name], isNotNull, reason: name);
        expect(FilterUtils.filterDisplayNames[name], isNot(contains('_')));
      }
    });

    test('formats a closed price range', () {
      expect(FilterUtils.formatRangeFilterDisplay('price', '100', '300'),
          r'Price: $100 - $300');
    });

    test('an open end of the price range reads as Any', () {
      expect(FilterUtils.formatRangeFilterDisplay('price', '300', ''),
          r'Price: $300 - Any');
      expect(FilterUtils.formatRangeFilterDisplay('price', '', '200'),
          r'Price: Any - $200');
    });
  });
}
