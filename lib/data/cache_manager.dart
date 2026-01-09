import 'dart:convert';
import 'package:hive/hive.dart';

/// Cache entry model to store data with expiration
class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'data': data,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        data: json['data'],
        expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt']),
      );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Application-level HTTP cache manager using Hive
/// Works on all platforms (web uses IndexedDB, mobile uses native storage)
class CacheManager {
  static const String _boxName = 'http_cache';
  static CacheManager? _instance;
  Box? _box;

  CacheManager._();

  static CacheManager get instance {
    _instance ??= CacheManager._();
    return _instance!;
  }

  /// Initialize the cache (must be called before first use)
  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  /// Get or fetch data with caching
  Future<T> call<T>({
    required String key,
    required Future<T> Function() remote,
    required T Function(dynamic json) fromJson,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    await initialize();

    // If force refresh, skip cache and fetch fresh data
    if (!forceRefresh) {
      final cached = await _getFromCache(key);
      if (cached != null) {
        return fromJson(cached);
      }
    }

    // Fetch fresh data
    final freshData = await remote();

    // Cache the fresh data
    if (cacheDuration != null) {
      await _saveToCache(key, freshData, cacheDuration);
    }

    return freshData;
  }

  /// Get data from cache if not expired
  Future<dynamic> _getFromCache(String key) async {
    final box = _box!;
    final cachedJson = box.get(key);

    if (cachedJson == null) return null;

    try {
      final entry = CacheEntry.fromJson(
        Map<String, dynamic>.from(json.decode(cachedJson)),
      );

      if (entry.isExpired) {
        await box.delete(key);
        return null;
      }

      return entry.data;
    } catch (e) {
      // Invalid cache entry, delete it
      await box.delete(key);
      return null;
    }
  }

  /// Save data to cache with expiration
  Future<void> _saveToCache(
    String key,
    dynamic data,
    Duration duration,
  ) async {
    final box = _box!;
    final entry = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration),
    );

    await box.put(key, json.encode(entry.toJson()));
  }

  /// Clear a specific cache entry by key
  Future<void> clearCacheForKey(String key) async {
    await initialize();
    await _box!.delete(key);
  }

  /// Clear all cache entries matching a pattern (contains)
  /// Example: clearCacheByPattern('listings') clears all listing-related caches
  Future<int> clearCacheByPattern(String pattern) async {
    await initialize();
    final box = _box!;
    int cleared = 0;

    final keysToDelete = <dynamic>[];
    for (var key in box.keys) {
      if (key.toString().contains(pattern)) {
        keysToDelete.add(key);
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
      cleared++;
    }

    return cleared;
  }

  /// Clear all cache entries
  Future<void> clearCache() async {
    await initialize();
    await _box!.clear();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    await initialize();
    final box = _box!;
    int totalEntries = box.length;
    int expiredEntries = 0;

    for (var key in box.keys) {
      final cachedJson = box.get(key);
      if (cachedJson != null) {
        try {
          final entry = CacheEntry.fromJson(
            Map<String, dynamic>.from(json.decode(cachedJson)),
          );
          if (entry.isExpired) expiredEntries++;
        } catch (e) {
          expiredEntries++;
        }
      }
    }

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'validEntries': totalEntries - expiredEntries,
    };
  }

  /// Clean up expired entries (useful for maintenance)
  Future<int> cleanExpired() async {
    await initialize();
    final box = _box!;
    int cleaned = 0;

    final keysToDelete = <dynamic>[];
    for (var key in box.keys) {
      final cachedJson = box.get(key);
      if (cachedJson != null) {
        try {
          final entry = CacheEntry.fromJson(
            Map<String, dynamic>.from(json.decode(cachedJson)),
          );
          if (entry.isExpired) {
            keysToDelete.add(key);
          }
        } catch (e) {
          keysToDelete.add(key);
        }
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
      cleaned++;
    }

    return cleaned;
  }
}
