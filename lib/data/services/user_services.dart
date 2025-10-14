import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:motorix_app/utils/utils.dart';

class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<String> signUp(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    try {
      http.Response response = await apiClient.post('/user/signup', {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      });

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      return response.body;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException(
        'Network error during sign up',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      http.Response response = await apiClient.post('/user/signin', {
        'email': email,
        'password': password,
      });

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await _storeAuthData(data);
        return data;
      } catch (e) {
        throw DataParseException(
          'Invalid response format',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AuthException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error during sign in',
        details: e.toString(),
      );
    }
  }

  Future<void> _storeAuthData(Map<String, dynamic> responseData) async {
    try {
      await SecureStorage.write('userId', responseData['userId'] ?? '');

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

  Future<String> signOut() async {
    try {
      final userId = await apiClient.getUserId();

      if (userId == null) {
        throw UnauthenticatedException('User not signed in');
      }

      http.Response response = await apiClient.post('/user/signout', {
        'currentUserId': userId,
      });

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      await _clearAuthData();

      return response.body;
    } catch (e) {
      if (e is UnauthenticatedException || e is AuthException) rethrow;
      throw NetworkException(
        'Network error during sign out',
        details: e.toString(),
      );
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await SecureStorage.delete('userId');

      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    } catch (e) {
      // Log error but don't fail the sign-out
      // In production, use a proper logging framework
    }
  }

  Future<User> getUserWithId(String userId) async {
    try {
      http.Response response = await apiClient.get('/users/$userId');

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException('User not found with ID: $userId');
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          'Failed to get user',
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        return User.fromJsonString(response.body);
      } catch (e) {
        throw DataParseException(
          'Failed to parse user data',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NotFoundException ||
          e is NetworkException ||
          e is DataParseException) {
        rethrow;
      }
      throw NetworkException(
        'Network error getting user',
        details: e.toString(),
      );
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      http.Response response = await apiClient.post('/user/forgot-password', {
        'email': email,
      });

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      return response.body;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException(
        'Network error during password reset request',
        details: e.toString(),
      );
    }
  }

  Future<String> resetPassword(String newPassword) async {
    try {
      http.Response response = await apiClient.post('/user/change-password', {
        'newPassword': newPassword,
      }, forceAuthHeader: true);

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      return response.body;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException(
        'Network error during password reset',
        details: e.toString(),
      );
    }
  }

  Future<void> refreshSession() async {
    try {
      final Map<String, dynamic> requestBody = {};

      if (!kIsWeb) {
        final refreshToken = await SecureStorage.read('refreshToken');
        if (refreshToken == null || refreshToken.isEmpty) {
          throw UnauthenticatedException(
            'No refresh token available',
            details: 'User needs to sign in again',
          );
        }

        requestBody['refreshToken'] = refreshToken;
      }

      http.Response response = await apiClient.post(
        '/user/refresh-token',
        requestBody,
      );

      if (response.statusCode == HttpStatus.unauthorized) {
        final errorMessage = extractErrorMessage(response.body);
        throw UnauthenticatedException(errorMessage, details: response.body);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await _storeAuthData(data);
      } catch (e) {
        throw DataParseException(
          'Failed to parse refresh response',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is UnauthenticatedException ||
          e is AuthException ||
          e is DataParseException) {
        rethrow;
      }
      throw NetworkException(
        'Network error during session refresh',
        details: e.toString(),
      );
    }
  }

  Future<String> changePassword(String newPassword) async {
    try {
      http.Response response = await apiClient.post('/user/change-password', {
        'newPassword': newPassword,
      });

      if (response.statusCode == HttpStatus.unauthorized) {
        final errorMessage = extractErrorMessage(response.body);
        throw UnauthenticatedException(errorMessage, details: response.body);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      return response.body;
    } catch (e) {
      if (e is UnauthenticatedException || e is AuthException) rethrow;
      throw NetworkException(
        'Network error during password change',
        details: e.toString(),
      );
    }
  }
}
