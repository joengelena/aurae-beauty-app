import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:motorix_app/utils/secure_storage.dart';

class ApiClient {
  final String _baseUrl = 'http://localhost:4941/api/v1';
  static final http.Client _client = http.Client();

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final String? authToken = await SecureStorage.read('authToken');
    final String? csrfToken = await SecureStorage.read('csrfToken');

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'mtx-auth-token': authToken ?? '',
        'mtx-csrf-token': csrfToken ?? '',
      },
    );

    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    String? authToken = await SecureStorage.read('authToken');
    String? csrfToken = await SecureStorage.read('csrfToken');

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'content-type': 'application/json',
        'mtx-auth-token': authToken ?? '',
        'mtx-csrf-token': csrfToken ?? '',
      },
      body: jsonEncode(data),
    );

    if (path == '/user/signin') {
      final res = jsonDecode(response.body);
      await SecureStorage.write('authToken', res['authToken']);
      await SecureStorage.write('csrfToken', res['csrfToken']);
    }

    if (path == '/user/signout') {
      await SecureStorage.delete('authToken');
      await SecureStorage.delete('csrfToken');
    }

    return response;
  }
}
