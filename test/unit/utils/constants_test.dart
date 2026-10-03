import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/utils/constants.dart';

/// How ApiClient._invalidateCacheKeys + CacheManager.clearCacheByPattern treat
/// an invalidation entry: '*pattern*' clears every key containing pattern;
/// anything else clears exactly that key.
bool _invalidates(String entry, String key) {
  if (entry.startsWith('*') && entry.endsWith('*')) {
    return key.contains(entry.substring(1, entry.length - 1));
  }
  return entry == key;
}

void main() {
  group('CacheKeys per-dress keys', () {
    test('are distinct for different dresses', () {
      final builders = <String, String Function(int)>{
        'dress': CacheKeys.dress,
        'dressBookings': CacheKeys.dressBookings,
        'dressDamageIncidents': CacheKeys.dressDamageIncidents,
        'publicDressBookings': CacheKeys.publicDressBookings,
        'publicDamageIncidents': CacheKeys.publicDamageIncidents,
        'listing': CacheKeys.listing,
      };
      builders.forEach((name, build) {
        final keys = {for (final id in [1, 2, 12, 21, 123]) build(id)};
        expect(keys, hasLength(5), reason: '$name collides across ids');
      });
    });

    test('are distinct across kinds for the same dress', () {
      final keys = {
        CacheKeys.dress(5),
        CacheKeys.dressBookings(5),
        CacheKeys.dressDamageIncidents(5),
        CacheKeys.publicDressBookings(5),
        CacheKeys.publicDamageIncidents(5),
        CacheKeys.listing(5),
        CacheKeys.dresses,
      };
      expect(keys, hasLength(7));
    });

    test('are deterministic', () {
      expect(CacheKeys.dress(42), CacheKeys.dress(42));
      expect(CacheKeys.publicDressBookings(42),
          CacheKeys.publicDressBookings(42));
    });
  });

  group('CacheKeys.buildCacheKey', () {
    test('with no parameters is just the path', () {
      expect(CacheKeys.buildCacheKey('/dresses'), '/dresses');
      expect(CacheKeys.buildCacheKey('/dresses', queryParameters: {}),
          '/dresses');
    });

    test('does not depend on parameter order', () {
      expect(
        CacheKeys.buildCacheKey('/dresses',
            queryParameters: {'size': '8', 'brand': 'Zimmermann', 'limit': 10}),
        CacheKeys.buildCacheKey('/dresses',
            queryParameters: {'limit': 10, 'brand': 'Zimmermann', 'size': '8'}),
      );
    });

    test('different queries get different keys', () {
      final a = CacheKeys.buildCacheKey('/dresses',
          queryParameters: {'pageNumber': 1});
      final b = CacheKeys.buildCacheKey('/dresses',
          queryParameters: {'pageNumber': 2});
      final c = CacheKeys.buildCacheKey('/dresses',
          queryParameters: {'pageNumber': 1, 'q': 'silk'});
      expect({a, b, c}, hasLength(3));
    });
  });

  group('CacheKeys invalidation patterns', () {
    test('allPublicDressBookings clears every dress\'s public availability',
        () {
      for (final id in [1, 7, 42]) {
        expect(
          _invalidates(
              CacheKeys.allPublicDressBookings, CacheKeys.publicDressBookings(id)),
          isTrue,
          reason: 'dress $id',
        );
      }
    });

    test('allPublicDressBookings leaves owner-side keys alone', () {
      for (final key in [
        CacheKeys.dresses,
        CacheKeys.dress(7),
        CacheKeys.dressBookings(7),
        CacheKeys.userBookings,
      ]) {
        expect(_invalidates(CacheKeys.allPublicDressBookings, key), isFalse,
            reason: key);
      }
    });

    test('the */dresses* wildcard used by dress writes reaches every cached '
        'view of a dress', () {
      // DressServices add/update/delete invalidate
      // [CacheKeys.dresses, CacheKeys.dress(id), '*/dresses*'] so the owner's
      // Wardrobe and the public side both refresh (see data-layer.md).
      const wildcard = '*/dresses*';
      final browseFeed = CacheKeys.buildCacheKey('/dresses',
          queryParameters: {'limit': 10, 'pageNumber': 1});
      expect(_invalidates(wildcard, CacheKeys.dresses), isTrue);
      expect(_invalidates(wildcard, CacheKeys.dress(7)), isTrue);
      expect(_invalidates(wildcard, browseFeed), isTrue);
      expect(_invalidates(wildcard, CacheKeys.listing(7)), isTrue,
          reason: 'public dress detail stays cached after the owner edits it');
    });
  });

  group('CacheDurations', () {
    test('user data expires before public data, before static config', () {
      expect(CacheDurations.short < CacheDurations.medium, isTrue);
      expect(CacheDurations.medium < CacheDurations.long, isTrue);
    });
  });
}
