import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shine_app/data/api_client.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/pagination.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/utils.dart';

class DressServices {
  static final ApiClient apiClient = ApiClient();

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
      filename: 'dress_image.$extension',
      contentType: contentType,
    );
  }

  Future<Map<String, dynamic>> addDress(
    Map<String, dynamic> dressData, {
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      http.Response response;

      if (imageBytes != null) {
        final fields = <String, String>{};
        dressData.forEach((key, value) {
          fields[key] = value.toString();
        });

        final multipartFile = _createImageMultipartFile(imageBytes, imageMimeType);

        response = await apiClient.postMultipart(
          '/user/dresses',
          fields,
          [multipartFile],
          invalidateCacheKeys: [CacheKeys.dresses],
        );
      } else {
        response = await apiClient.post(
          '/user/dresses',
          dressData,
          invalidateCacheKeys: [CacheKeys.dresses],
        );
      }

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error while adding dress', details: e.toString());
    }
  }

  Future<List<BusinessDress>> getAllDresses() async {
    try {
      http.Response response = await apiClient.get(
        '/user/dresses',
        cacheKey: CacheKeys.dresses,
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((d) => BusinessDress.fromJson(d as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error while fetching dresses', details: e.toString());
    }
  }

  Future<BusinessDress> getDressById(int id) async {
    try {
      http.Response response = await apiClient.get(
        '/user/dresses/$id',
        cacheKey: CacheKeys.dress(id),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BusinessDress.fromJson(data);
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error while fetching dress', details: e.toString());
    }
  }

  Future<void> updateDress(
    int dressId,
    Map<String, Object> dressFields, {
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      http.Response response;

      if (imageBytes != null) {
        final fields = <String, String>{};
        dressFields.forEach((key, value) {
          fields[key] = value.toString();
        });

        final multipartFile = _createImageMultipartFile(imageBytes, imageMimeType);

        response = await apiClient.patchMultipart(
          '/user/dresses/$dressId',
          fields,
          [multipartFile],
          invalidateCacheKeys: [CacheKeys.dresses, CacheKeys.dress(dressId)],
        );
      } else {
        final payload = Map<String, dynamic>.fromEntries(dressFields.entries);

        response = await apiClient.patch(
          '/user/dresses/$dressId',
          payload,
          invalidateCacheKeys: [CacheKeys.dresses, CacheKeys.dress(dressId)],
        );
      }

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException(extractErrorMessage(response.body));
      }
      if (response.statusCode == HttpStatus.forbidden) {
        throw ForbiddenException(extractErrorMessage(response.body));
      }
      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is NotFoundException || e is ForbiddenException || e is NetworkException) rethrow;
      throw NetworkException('Network error updating dress', details: e.toString());
    }
  }

  Future<void> deleteDress(int dressId) async {
    try {
      http.Response response = await apiClient.delete(
        '/user/dresses/$dressId',
        {},
        invalidateCacheKeys: [CacheKeys.dresses, CacheKeys.dress(dressId)],
      );

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException(extractErrorMessage(response.body));
      }
      if (response.statusCode == HttpStatus.forbidden) {
        throw ForbiddenException(extractErrorMessage(response.body));
      }
      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is NotFoundException || e is ForbiddenException || e is NetworkException) rethrow;
      throw NetworkException('Network error deleting dress', details: e.toString());
    }
  }

  Future<List<RentalBooking>> getBookingsByDressId(int dressId) async {
    try {
      http.Response response = await apiClient.get(
        '/user/dresses/$dressId/bookings',
        cacheKey: CacheKeys.dressBookings(dressId),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((b) => RentalBooking.fromJson(b as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching bookings', details: e.toString());
    }
  }

  Future<Map<String, dynamic>> addBooking(Map<String, dynamic> bookingData) async {
    try {
      final dressId = bookingData['dressIdFk'];

      http.Response response = await apiClient.post(
        '/user/dress-bookings',
        bookingData,
        invalidateCacheKeys: [CacheKeys.dressBookings(dressId)],
      );

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error while adding booking', details: e.toString());
    }
  }

  Future<PaginatedResponse<Listing>> getPublicDresses({
    Map<String, dynamic>? allQueries,
  }) async {
    try {
      final response = await apiClient.get(
        '/dresses',
        queryParameters: allQueries,
      );

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        return PaginatedResponse<Listing>.fromJson(
          body,
          (json) => Listing.fromJson(json),
        );
      } catch (e) {
        throw DataParseException('Failed to parse dresses', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching dresses', details: e.toString());
    }
  }

  Future<void> deleteBooking(int bookingId, int dressId) async {
    try {
      http.Response response = await apiClient.delete(
        '/user/dress-bookings/$bookingId',
        {},
        invalidateCacheKeys: [CacheKeys.dressBookings(dressId)],
      );

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException(extractErrorMessage(response.body));
      }
      if (response.statusCode == HttpStatus.forbidden) {
        throw ForbiddenException(extractErrorMessage(response.body));
      }
      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is NotFoundException || e is ForbiddenException || e is NetworkException) rethrow;
      throw NetworkException('Network error deleting booking', details: e.toString());
    }
  }
}
