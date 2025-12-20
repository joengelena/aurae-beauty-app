import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:fetch_client/fetch_client.dart';

class ApiClient {
  final String _baseUrl =
      'https://motorix-api-production.up.railway.app/api/v1';
  // final String _baseUrl = 'http://localhost:4941/api/v1';

  static final _client =
      kIsWeb
          ? FetchClient(
            mode: RequestMode.cors,
            credentials: RequestCredentials.cors,
          )
          : http.Client();

  // Flag to prevent infinite retry loops
  bool _isRefreshing = false;

  /// Build base headers for API requests
  Map<String, String> _buildHeaders({bool includeContentType = true}) {
    final headers = <String, String>{
      'x-client-type': kIsWeb ? 'web' : 'flutter',
    };

    if (includeContentType) {
      headers['content-type'] = 'application/json';
    }

    return headers;
  }

  /// Add authorization header for mobile platforms
  Future<void> _addAuthHeader(
    Map<String, String> headers, {
    bool forceForWeb = false,
  }) async {
    if (!kIsWeb || forceForWeb) {
      final accessToken = await SecureStorage.read('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['authorization'] = 'Bearer $accessToken';
      }
    }
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final headers = _buildHeaders();
      await _addAuthHeader(headers);

      return await _client.get(uri, headers: headers);
    });
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> data, {
    bool forceAuthHeader = false,
  }) async {
    // Skip retry for auth endpoints to avoid infinite loops
    final skipRetry =
        path.contains('/signin') ||
        path.contains('/signup') ||
        path.contains('/refresh-token');

    return _executeWithRetry(() async {
      final headers = _buildHeaders();
      await _addAuthHeader(headers, forceForWeb: forceAuthHeader);

      return await _client.post(
        Uri.parse('$_baseUrl$path'),
        headers: headers,
        body: jsonEncode(data),
      );
    }, skipRetry: skipRetry);
  }

  Future<http.Response> patch(String path, Map<String, dynamic> data) async {
    return _executeWithRetry(() async {
      final headers = _buildHeaders();
      await _addAuthHeader(headers);

      return await _client.patch(
        Uri.parse('$_baseUrl$path'),
        headers: headers,
        body: jsonEncode(data),
      );
    });
  }

  Future<http.Response> delete(String path, Map<String, dynamic> data) async {
    return _executeWithRetry(() async {
      final headers = _buildHeaders();
      await _addAuthHeader(headers);

      final request = http.Request('DELETE', Uri.parse('$_baseUrl$path'));
      request.headers.addAll(headers);
      request.body = jsonEncode(data);

      final streamedResponse = await _client.send(request);
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    return _executeWithRetry(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$path'),
      );

      // Multipart requests don't use content-type header (set automatically)
      final headers = _buildHeaders(includeContentType: false);
      await _addAuthHeader(headers);
      request.headers.addAll(headers);

      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await _client.send(request);
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<http.Response> patchMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    return _executeWithRetry(() async {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl$path'),
      );

      // Multipart requests don't use content-type header (set automatically)
      final headers = _buildHeaders(includeContentType: false);
      await _addAuthHeader(headers);
      request.headers.addAll(headers);

      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await _client.send(request);
      return await http.Response.fromStream(streamedResponse);
    });
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }

  /// Refresh the access token using the refresh token
  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      return false; // Already refreshing, avoid infinite loop
    }

    _isRefreshing = true;

    try {
      // Build request body - include refresh token for mobile
      final requestBody = <String, dynamic>{};
      if (!kIsWeb) {
        final refreshToken = await SecureStorage.read('refreshToken');
        if (refreshToken == null || refreshToken.isEmpty) {
          return false;
        }
        requestBody['refreshToken'] = refreshToken;
      }

      // Make refresh request without retry logic to avoid infinite loop
      final response = await _client.post(
        Uri.parse('$_baseUrl/user/refresh-token'),
        headers: _buildHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != HttpStatus.ok) {
        return false;
      }

      // Store new tokens (mobile only - web tokens are in httpOnly cookies)
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

  /// Execute a request with automatic retry on 401 errors
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    bool skipRetry = false,
  }) async {
    final response = await request();

    // If 401 and not already retrying, attempt token refresh and retry
    if (response.statusCode == HttpStatus.unauthorized && !skipRetry) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request with new token
        return await request();
      }
    }

    return response;
  }
}
