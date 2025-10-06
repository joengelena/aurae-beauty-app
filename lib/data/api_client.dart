import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:motorix_app/utils/secure_storage.dart';

class ApiClient {
  final String _baseUrl = 'http://localhost:4941/api/v1';
  final String _baseUrlV2 = 'http://localhost:4941/api/v1/v2'; // Supabase routes
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

    if (path == '/user/signin' && response.statusCode == 200) {
      final res = jsonDecode(response.body);
      await SecureStorage.write('authToken', res['authToken'] ?? '');
      await SecureStorage.write('csrfToken', res['csrfToken'] ?? '');
    }

    if (path == '/user/signout') {
      await SecureStorage.delete('authToken');
      await SecureStorage.delete('csrfToken');
    }

    return response;
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final authToken = await SecureStorage.read('authToken');
    final csrfToken = await SecureStorage.read('csrfToken');

    final uri = Uri.parse('$_baseUrl$path');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['mtx-auth-token'] = authToken ?? ''
          ..headers['mtx-csrf-token'] = csrfToken ?? ''
          ..fields.addAll(fields)
          ..files.addAll(files);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return response;
  }

  // V2 API methods for Supabase authentication
  Future<http.Response> postV2(String path, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrlV2$path'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // Store user ID from successful signin
    if (path == '/user/signin' && response.statusCode == 200) {
      final res = jsonDecode(response.body);
      await SecureStorage.write('userId', res['userId'] ?? '');
    }

    // Clear user ID on signout
    if (path == '/user/signout') {
      await SecureStorage.delete('userId');
    }

    return response;
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await SecureStorage.read('userId');
  }
}
