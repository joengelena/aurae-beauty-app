import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:fetch_client/fetch_client.dart';

class ApiClient {
  final String _baseUrl = 'http://localhost:4941/api/v1';

  static final _client =
      kIsWeb
          ? FetchClient(
            mode: RequestMode.cors,
            credentials: RequestCredentials.cors,
          )
          : http.Client();

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final headers = <String, String>{'Content-Type': 'application/json'};

    // Only add authorization header for mobile (web uses cookies)
    if (!kIsWeb) {
      final String? accessToken = await SecureStorage.read('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['authorization'] = 'Bearer $accessToken';
      }
    }

    final response = await _client.get(uri, headers: headers);

    return response;
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> data, {
    bool forceAuthHeader = false,
  }) async {
    final headers = <String, String>{
      'content-type': 'application/json',
      'x-client-type': kIsWeb ? 'web' : 'flutter',
    };

    // Add authorization header for mobile, or when forced (e.g., password reset)
    if (!kIsWeb || forceAuthHeader) {
      final String? accessToken = await SecureStorage.read('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['authorization'] = 'Bearer $accessToken';
      }
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    // Only add authorization header for mobile (web uses cookies via FetchClient)
    if (!kIsWeb) {
      final String? accessToken = await SecureStorage.read('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['authorization'] = 'Bearer $accessToken';
      }
    }

    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    return response;
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }
}
