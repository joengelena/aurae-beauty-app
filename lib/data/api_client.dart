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
    final String? accessToken = await SecureStorage.read('accessToken');

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken ?? '',
      },
    );

    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    String? accessToken = await SecureStorage.read('accessToken');

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'content-type': 'application/json',
        'authorization': accessToken ?? '',
        'x-client-type': kIsWeb ? 'web' : 'flutter',
      },
      body: jsonEncode(data),
    );

    if (!kIsWeb) {
      if (path == '/user/signin' && response.statusCode == 200) {
        final res = jsonDecode(response.body);
        await SecureStorage.write(
          'accessToken',
          "Bearer ${res['accessToken']}",
        );
        await SecureStorage.write('refreshToken', res['refreshToken'] ?? '');
      }

      if (path == '/user/signout') {
        await SecureStorage.delete('accessToken');
      }
    }

    return response;
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final accessToken = await SecureStorage.read('accessToken');

    final uri = Uri.parse('$_baseUrl$path');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['authorization'] = accessToken ?? ''
          ..fields.addAll(fields)
          ..files.addAll(files);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return response;
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }
}
