import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/http_client.dart';
import 'package:motorix_app/data/cache_manager.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class ApiClient {
  final String _baseUrl =
      'https://motorix-api-production.up.railway.app/api/v1';
  // final String _baseUrl = 'http://localhost:4941/api/v1';

  late final http.Client _client;

  bool _isRefreshing = false;

  // Auth endpoints that should skip retry to avoid infinite loops
  static const _authEndpoints = ['/signin', '/signup', '/refresh-token'];

  ApiClient() {
    _client = HttpClientFactory.getClient();
  }

  /// Build complete URL from path
  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$_baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders({
    bool includeContentType = true,
    bool forceAuthForWeb = false,
  }) async {
    final headers = <String, String>{
      'x-client-type': kIsWeb ? 'web' : 'flutter',
    };

    if (includeContentType) {
      headers['content-type'] = 'application/json';
    }

    // Add auth header for mobile or when forced for web
    if (!kIsWeb || forceAuthForWeb) {
      final accessToken = await SecureStorage.read('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['authorization'] = 'Bearer $accessToken';
      }
    }

    return headers;
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      return false;
    }

    _isRefreshing = true;

    try {
      final requestBody = <String, dynamic>{};
      if (!kIsWeb) {
        final refreshToken = await SecureStorage.read('refreshToken');
        if (refreshToken == null || refreshToken.isEmpty) {
          return false;
        }
        requestBody['refreshToken'] = refreshToken;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/user/refresh-token'),
        headers: await _buildHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode != HttpStatus.ok) {
        return false;
      }

      if (!kIsWeb) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await SecureStorage.write('userId', data['userId'] ?? '');
        await SecureStorage.write('accessToken', data['accessToken'] ?? '');
        await SecureStorage.write('refreshToken', data['refreshToken'] ?? '');
      }

      return true;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    bool skipRetry = false,
  }) async {
    final response = await request();

    if (response.statusCode == HttpStatus.unauthorized && !skipRetry) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        return await request();
      }
    }

    return response;
  }

  bool _shouldSkipRetry(String path) {
    return _authEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Invalidate specified cache keys after successful mutations
  /// Supports both specific keys and pattern matching:
  /// - Specific key: "listings/123" - clears only that key
  /// - Pattern: "*listings*" - clears all keys containing "listings"
  Future<void> _invalidateCacheKeys(List<String>? cacheKeys) async {
    if (cacheKeys == null || cacheKeys.isEmpty) return;

    try {
      for (final key in cacheKeys) {
        if (key.startsWith('*') && key.endsWith('*')) {
          // Pattern-based invalidation: *pattern*
          final pattern = key.substring(1, key.length - 1);
          final cleared = await CacheManager.instance.clearCacheByPattern(
            pattern,
          );
          debugPrint(
            '🗑️ Invalidated $cleared cache entries matching: *$pattern*',
          );
        } else {
          await CacheManager.instance.clearCacheForKey(key);
          debugPrint('🗑️ Invalidated cache: $key');
        }
      }
    } catch (e) {
      // Log error but don't fail the request
      debugPrint('Cache invalidation error: $e');
    }
  }

  Future<http.Response> get(
    String path, {
    required String cacheKey,
    required Duration cacheDuration,
    Map<String, dynamic>? queryParameters,
    bool bypassCache = false,
  }) async {
    try {
      final cachedData = await CacheManager.instance.call<dynamic>(
        key: cacheKey,
        remote: () async {
          final response = await _executeWithRetry(() async {
            try {
              final uri = _buildUri(path, queryParameters: queryParameters);
              final headers = await _buildHeaders();
              return await _client.get(uri, headers: headers);
            } catch (e) {
              return http.Response('Network error: ${e.toString()}', 500);
            }
          }, skipRetry: _shouldSkipRetry(path));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return json.decode(response.body);
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.body}');
          }
        },
        fromJson: (data) => data,
        forceRefresh: bypassCache,
        cacheDuration: cacheDuration,
      );

      return http.Response(json.encode(cachedData), 200);
    } catch (e) {
      // If caching fails, fall back to direct HTTP request
      return _executeWithRetry(() async {
        try {
          final uri = _buildUri(path, queryParameters: queryParameters);
          final headers = await _buildHeaders();
          return await _client.get(uri, headers: headers);
        } catch (e) {
          return http.Response('Network error: ${e.toString()}', 500);
        }
      }, skipRetry: _shouldSkipRetry(path));
    }
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> data, {
    bool forceAuthHeader = false,
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _executeWithRetry(() async {
      try {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(forceAuthForWeb: forceAuthHeader);

        return await _client.post(
          uri,
          headers: headers,
          body: json.encode(data),
        );
      } catch (e) {
        return http.Response('Network error: ${e.toString()}', 500);
      }
    }, skipRetry: _shouldSkipRetry(path));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _invalidateCacheKeys(invalidateCacheKeys);
    }

    return response;
  }

  Future<http.Response> patch(
    String path,
    Map<String, dynamic> data, {
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _executeWithRetry(() async {
      try {
        final uri = _buildUri(path);
        final headers = await _buildHeaders();

        return await _client.patch(
          uri,
          headers: headers,
          body: json.encode(data),
        );
      } catch (e) {
        return http.Response('Network error: ${e.toString()}', 500);
      }
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _invalidateCacheKeys(invalidateCacheKeys);
    }

    return response;
  }

  Future<http.Response> delete(
    String path,
    Map<String, dynamic> data, {
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _executeWithRetry(() async {
      try {
        final uri = _buildUri(path);
        final headers = await _buildHeaders();

        return await _client.delete(
          uri,
          headers: headers,
          body: json.encode(data),
        );
      } catch (e) {
        return http.Response('Network error: ${e.toString()}', 500);
      }
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _invalidateCacheKeys(invalidateCacheKeys);
    }

    return response;
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _executeWithRetry(() async {
      try {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(includeContentType: false);

        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);
        request.fields.addAll(fields);
        request.files.addAll(files);

        final streamedResponse = await _client.send(request);
        return await http.Response.fromStream(streamedResponse);
      } catch (e) {
        return http.Response('Network error: ${e.toString()}', 500);
      }
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _invalidateCacheKeys(invalidateCacheKeys);
    }

    return response;
  }

  Future<http.Response> patchMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _executeWithRetry(() async {
      try {
        final uri = _buildUri(path);
        final headers = await _buildHeaders(includeContentType: false);

        final request = http.MultipartRequest('PATCH', uri);
        request.headers.addAll(headers);
        request.fields.addAll(fields);
        request.files.addAll(files);

        final streamedResponse = await _client.send(request);
        return await http.Response.fromStream(streamedResponse);
      } catch (e) {
        return http.Response('Network error: ${e.toString()}', 500);
      }
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _invalidateCacheKeys(invalidateCacheKeys);
    }

    return response;
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }

  /// Clear all cached data (e.g., on sign out)
  Future<void> clearCache() async {
    await CacheManager.instance.clearCache();
  }

  /// Clear cache for a specific key
  Future<void> clearCacheForKey(String key) async {
    await CacheManager.instance.clearCacheForKey(key);
  }
}
