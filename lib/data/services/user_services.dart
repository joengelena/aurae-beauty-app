import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/utils/secure_storage.dart';

class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<ApiResponse> signUp(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    http.Response response = await apiClient.post('/user/signup', {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    if (response.statusCode != HttpStatus.created) {
      return ApiResponse.failure('Failed to sign up');
    }

    return ApiResponse.success(response.body);
  }

  Future<ApiResponse> signIn(String email, String password) async {
    http.Response response = await apiClient.post('/user/signin', {
      'email': email,
      'password': password,
    });

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure(response.body);
    }

    // Parse and store authentication data
    try {
      final data = json.decode(response.body);

      // Store authentication data based on platform
      await _storeAuthData(data);

      return ApiResponse.success(data);
    } catch (e) {
      return ApiResponse.failure('Invalid response format');
    }
  }

  /// Store authentication data after successful sign-in
  /// For mobile: stores userId, accessToken, and refreshToken
  /// For web: only stores userId (cookies handled by browser)
  Future<void> _storeAuthData(Map<String, dynamic> responseData) async {
    try {
      // Store userId for both platforms (needed for business logic)
      await SecureStorage.write('userId', responseData['userId'] ?? '');

      // For mobile: store tokens in secure storage
      // For web: tokens are in httpOnly cookies (handled by browser)
      if (!kIsWeb) {
        await SecureStorage.write(
          'accessToken',
          "Bearer ${responseData['accessToken'] ?? ''}",
        );
        await SecureStorage.write(
          'refreshToken',
          responseData['refreshToken'] ?? '',
        );
      }
    } catch (e) {
      // Log error but don't fail the sign-in
      // In production, use a proper logging framework
    }
  }

  Future<ApiResponse> signOut() async {
    // Get userId from secure storage
    final userId = await apiClient.getUserId();

    if (userId == null) {
      return ApiResponse.failure('User not signed in');
    }

    http.Response response = await apiClient.post('/user/signout', {
      'currentUserId': userId,
    });

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure('Failed to sign out');
    }

    // Clear authentication data after successful sign-out
    await _clearAuthData();

    return ApiResponse.success(response.body);
  }

  /// Clear authentication data after sign-out
  /// For mobile: deletes userId, accessToken, and refreshToken
  /// For web: only deletes userId (cookies cleared by server)
  Future<void> _clearAuthData() async {
    try {
      await SecureStorage.delete('userId');

      // For mobile: also delete tokens
      // For web: cookies are cleared by server (Set-Cookie with expired date)
      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    } catch (e) {
      // Log error but don't fail the sign-out
      // In production, use a proper logging framework
    }
  }

  Future<ApiResponse<User>> getUserWithId(String userId) async {
    http.Response response = await apiClient.get('/users/$userId');

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure('Failed to get user');
    }

    return ApiResponse<User>.success(User.fromJsonString(response.body));
  }

  Future<bool> refreshSession() async {
    try {
      final Map<String, dynamic> requestBody = {};

      if (!kIsWeb) {
        final refreshToken = await SecureStorage.read('refreshToken');
        if (refreshToken == null || refreshToken.isEmpty) {
          return false;
        }
        requestBody['refreshToken'] = refreshToken;
      }

      http.Response response = await apiClient.post(
        '/user/refresh-token',
        requestBody,
      );

      if (response.statusCode != HttpStatus.ok) {
        return false;
      }

      final data = json.decode(response.body);
      await _storeAuthData(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
