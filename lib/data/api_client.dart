import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:motorix_app/utils/secure_storage.dart';

class ApiClient {
  final String _baseUrl = 'http://localhost:4941/api/v1';
  static final http.Client _client = http.Client();

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Only add authorization header for mobile (web uses cookies)
    if (!kIsWeb) {
      final String? accessToken = await SecureStorage.read('accessToken');
      headers['authorization'] = accessToken ?? '';
    }

    final response = await _client.get(uri, headers: headers);

    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final headers = <String, String>{
      'content-type': 'application/json',
      'x-client-type': kIsWeb ? 'web' : 'flutter',
    };

    // Only add authorization header for mobile (web uses cookies)
    if (!kIsWeb) {
      final String? accessToken = await SecureStorage.read('accessToken');
      headers['authorization'] = accessToken ?? '';
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(data),
    );

    // Handle sign-in response
    if (path == '/user/signin' && response.statusCode == 200) {
      final res = jsonDecode(response.body);

      // Store userId for both platforms (needed for business logic)
      await SecureStorage.write('userId', res['userId']);

      // For mobile: store tokens in secure storage
      // For web: tokens are in httpOnly cookies (handled by browser)
      if (!kIsWeb) {
        await SecureStorage.write(
          'accessToken',
          "Bearer ${res['accessToken']}",
        );
        await SecureStorage.write('refreshToken', res['refreshToken']);
      }
    }

    // Handle sign-out response
    if (path == '/user/signout' && response.statusCode == 200) {
      await SecureStorage.delete('userId');

      // For mobile: also delete tokens
      // For web: cookies are cleared by server (Set-Cookie with expired date)
      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    }

    return response;
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    // Only add authorization header for mobile (web uses cookies)
    if (!kIsWeb) {
      final String? accessToken = await SecureStorage.read('accessToken');
      request.headers['authorization'] = accessToken ?? '';
    }

    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return response;
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }
}
