import 'dart:convert';
import 'dart:developer' as console;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shine_app/data/api_client.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_settings.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/env_constants.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:shine_app/utils/utils.dart';
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
          "The server sent something we couldn't read. Please try again.",
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AuthException || e is DataParseException) rethrow;
      throw NetworkException(
        "Couldn't reach the server while signing you up. Check your connection and try again.",
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
        // Cache keys aren't per-user, so anything cached under a previous
        // account (or signed-out browsing) must not be served to this one.
        await _clearCache();
        await _storeAuthData(data);
        return data;
      } catch (e) {
        throw DataParseException(
          "The server sent something we couldn't read. Please try again.",
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AuthException || e is DataParseException) rethrow;
      throw NetworkException(
        "Couldn't reach the server while signing you in. Check your connection and try again.",
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

  /// Signs out on the server, then always clears local auth data and the
  /// cache — even if the API call fails — so the stored tokens can't silently
  /// sign the user back in on the next launch.
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

      return response.body;
    } catch (e) {
      if (e is UnauthenticatedException || e is AuthException) rethrow;
      throw NetworkException(
        "Couldn't reach the server while signing you out. Check your connection and try again.",
        details: e.toString(),
      );
    } finally {
      await clearAuthData();
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
          "The server sent something we couldn't read. Please try again.",
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
        "Couldn't reach the server while loading your account. Check your connection and try again.",
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
        "Couldn't reach the server while resending the verification email. Check your connection and try again.",
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
        "Couldn't reach the server while requesting a password reset. Check your connection and try again.",
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
        "Couldn't reach the server while resetting your password. Check your connection and try again.",
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

      // Only a definitive rejection of the session means the tokens are dead.
      // Anything else — the synthetic 503 ApiClient returns when the network
      // is down, a 5xx, a rate limit — says nothing about the session, so it
      // must not cost the user their sign-in.
      if (response.statusCode == HttpStatus.unauthorized ||
          response.statusCode == HttpStatus.forbidden) {
        final errorMessage = extractErrorMessage(response.body);
        throw UnauthenticatedException(errorMessage, details: response.body);
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await _storeAuthData(data);
      } catch (e) {
        throw DataParseException(
          "The server sent something we couldn't read. Please try again.",
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is UnauthenticatedException ||
          e is NetworkException ||
          e is DataParseException) {
        rethrow;
      }
      throw NetworkException(
        "Couldn't reach the server while refreshing your session. Check your connection and try again.",
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
        "Couldn't reach the server while changing your password. Check your connection and try again.",
        details: e.toString(),
      );
    }
  }

  Future<String> deleteAccount(String password) async {
    try {
      http.Response response = await apiClient.delete('/user', {
        'currentPassword': password,
      });

      if (response.statusCode == HttpStatus.unauthorized) {
        final errorMessage = extractErrorMessage(response.body);
        throw UnauthenticatedException(errorMessage, details: response.body);
      }

      if (response.statusCode == HttpStatus.forbidden) {
        final errorMessage = extractErrorMessage(response.body);
        throw AuthException(errorMessage, details: response.body);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      await clearAuthData();

      return response.body;
    } catch (e) {
      if (e is UnauthenticatedException ||
          e is AuthException ||
          e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        "Couldn't reach the server while deleting your account. Check your connection and try again.",
        details: e.toString(),
      );
    }
  }

  Future<BusinessSettings> getBusinessSettings() async {
    try {
      final response = await apiClient.get(
        '/user/settings',
        cacheKey: CacheKeys.businessSettings,
        cacheDuration: CacheDurations.long,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BusinessSettings.fromJson(data);
      } catch (e) {
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading your settings. Check your connection and try again.", details: e.toString());
    }
  }

  Future<BusinessSettings> updateBusinessSettings(
    BusinessSettings settings,
    String userId,
  ) async {
    try {
      final response = await apiClient.patch(
        '/user/settings',
        settings.toJson(),
        // Business settings are joined onto the /users/:id response (e.g.
        // deliveryOption), so a cached profile fetch must be invalidated too —
        // otherwise callers that re-fetch the profile right after saving see
        // the stale pre-save value.
        invalidateCacheKeys: [
          CacheKeys.businessSettings,
          CacheKeys.userDetails(userId),
        ],
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BusinessSettings.fromJson(data);
      } catch (e) {
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while saving your settings. Check your connection and try again.", details: e.toString());
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

  /// Removes every trace of the signed-in account from the device: stored
  /// tokens and the HTTP cache (whose keys aren't per-user). Used by sign-out,
  /// delete-account and a rejected session refresh alike.
  Future<void> clearAuthData() async {
    try {
      await SecureStorage.delete('userId');
      await SecureStorage.delete('activeProfileIsBusiness');

      if (!kIsWeb) {
        await SecureStorage.delete('accessToken');
        await SecureStorage.delete('refreshToken');
      }
    } catch (e) {
      // Log error but don't fail
      debugPrint('⚠️ Failed to clear auth data: $e');
    }
    await _clearCache();
  }

  Future<void> _clearCache() async {
    try {
      await apiClient.clearCache();
    } catch (e) {
      // A stale cache is better than a failed sign-in/sign-out
      debugPrint('⚠️ Failed to clear cache: $e');
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
    String? instagram,
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
          if (instagram != null) 'instagram': instagram,
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
            if (instagram != null) 'instagram': instagram,
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
        "Couldn't reach the server while updating your profile. Check your connection and try again.",
        details: e.toString(),
      );
    }
  }
}
