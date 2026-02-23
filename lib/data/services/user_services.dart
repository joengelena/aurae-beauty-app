import 'dart:convert';
import 'dart:developer' as console;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user.dart';
import 'package:motorix_app/env_constants.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String location,
  ) async {
    try {
      http.Response response = await apiClient.post('/user/signup', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'location': location,
      });

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException(
          'Invalid signup response format',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AuthException || e is DataParseException) rethrow;
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
          responseData['accessToken'] ?? '',
        );
        await SecureStorage.write(
          'refreshToken',
          responseData['refreshToken'] ?? '',
        );
      }
    } catch (e) {
      // Log error but don't fail the sign-in
      debugPrint('⚠️ Failed to store auth data: $e');
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
      debugPrint('⚠️ Failed to clear auth data: $e');
    }
  }

  Future<User> getUserWithId(String userId) async {
    try {
      http.Response response = await apiClient.get(
        '/users/$userId',
        cacheKey: CacheKeys.userDetails(userId),
        cacheDuration: CacheDurations.short,
      );

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

  // Called directly on Supabase rather than through the API because
  // Supabase does not send emails when resend() is called server-side
  // with a service role key — it must originate from the client.
  Future<void> resendVerificationEmail(String email) async {
    try {
      console.log('Attempting to resend verification email for: $email');
      await supabase.Supabase.instance.client.auth.resend(
        type: supabase.OtpType.signup,
        email: email,
        emailRedirectTo: emailVerificationRedirectUrl,
      );
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message, details: e.statusCode);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException(
        'Network error resending verification email',
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
      http.Response response = await apiClient.post('/user/reset-password', {
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

  Future<void> signUpAndSignIn(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String location,
  ) async {
    await signUp(firstName, lastName, email, password, phoneNumber, location);
    await signIn(email, password);
  }

  Future<bool> checkAuthenticationStatus() async {
    try {
      final userId = await SecureStorage.read('userId');

      if (userId == null || userId.isEmpty) {
        return false;
      }

      try {
        await refreshSession();
        return true;
      } on UnauthenticatedException catch (_) {
        await clearAuthData();
        return false;
      } on AuthException catch (_) {
        await clearAuthData();
        return false;
      } on NetworkException catch (_) {
        // Network error - assume user is still authenticated
        // (offline mode support)
        return true;
      }
    } catch (e) {
      await clearAuthData();
      return false;
    }
  }

  Future<void> clearAuthData() async {
    try {
      await SecureStorage.delete('userId');

      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    } catch (e) {
      // Log error but don't fail
      debugPrint('⚠️ Failed to clear auth data: $e');
    }
  }

  static http.MultipartFile _createImageMultipartFile(
    Uint8List imageBytes,
    String? mimeType,
  ) {
    final resolvedMimeType = mimeType ?? 'image/jpeg';
    final mimeTypeParts = resolvedMimeType.split('/');

    String extension = 'jpg';
    if (mimeTypeParts.length > 1) {
      extension = mimeTypeParts[1].toLowerCase();
      if (extension == 'jpeg') extension = 'jpg';
    }

    final contentType = MediaType(
      mimeTypeParts[0],
      mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'jpeg',
    );

    return http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'profile_photo.$extension',
      contentType: contentType,
    );
  }

  Future<String> updateUser(
    String firstName,
    String lastName,
    String phoneNumber,
    String location,
    String userId, {
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      http.Response response;

      if (imageBytes != null) {
        final fields = <String, String>{
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'location': location,
        };

        final multipartFile = _createImageMultipartFile(
          imageBytes,
          imageMimeType,
        );
        response = await apiClient.patchMultipart(
          '/user',
          fields,
          [multipartFile],
          invalidateCacheKeys: [CacheKeys.userDetails(userId)],
        );
      } else {
        response = await apiClient.patch(
          '/user',
          {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'location': location,
          },
          invalidateCacheKeys: [CacheKeys.userDetails(userId)],
        );
      }

      if (response.statusCode == HttpStatus.unauthorized) {
        final errorMessage = extractErrorMessage(response.body);
        throw UnauthenticatedException(errorMessage, details: response.body);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      return response.body;
    } catch (e) {
      if (e is UnauthenticatedException || e is NetworkException) rethrow;
      throw NetworkException(
        'Network error during profile update',
        details: e.toString(),
      );
    }
  }
}
