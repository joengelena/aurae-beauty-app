import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shine_app/data/api_client.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/listing_attribute.dart';
import 'package:shine_app/data/models/pagination.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
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
      'images',
      imageBytes,
      filename: 'dress_image.$extension',
      contentType: contentType,
    );
  }

  Future<Map<String, dynamic>> addDress(
    Map<String, dynamic> dressData, {
    List<Uint8List> photoBytes = const [],
    List<String?> photoMimeTypes = const [],
  }) async {
    try {
      http.Response response;

      if (photoBytes.isNotEmpty) {
        final fields = <String, String>{};
        dressData.forEach((key, value) {
          fields[key] = value is List ? json.encode(value) : value.toString();
        });

        final multipartFiles = List.generate(
          photoBytes.length,
          (i) => _createImageMultipartFile(
            photoBytes[i],
            i < photoMimeTypes.length ? photoMimeTypes[i] : null,
          ),
        );

        response = await apiClient.postMultipart(
          '/user/dresses',
          fields,
          multipartFiles,
          invalidateCacheKeys: [CacheKeys.dresses, '*/dresses*'],
        );
      } else {
        response = await apiClient.post(
          '/user/dresses',
          dressData,
          invalidateCacheKeys: [CacheKeys.dresses, '*/dresses*'],
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
    List<Uint8List> newPhotoBytes = const [],
    List<String?> newPhotoMimeTypes = const [],
    List<String> keepPhotoUrls = const [],
    List<DateTimeRange>? blockedDateRanges,
  }) async {
    try {
      http.Response response;

      final fields = <String, String>{};
      dressFields.forEach((key, value) {
        fields[key] = value is List ? json.encode(value) : value.toString();
      });
      fields['keepPhotoUrls'] = json.encode(keepPhotoUrls);
      if (blockedDateRanges != null) {
        fields['blockedDateRanges'] = json.encode(
          blockedDateRanges
              .map((r) => {
                    'startDate': r.start.toIso8601String().substring(0, 10),
                    'endDate': r.end.toIso8601String().substring(0, 10),
                  })
              .toList(),
        );
      }

      final multipartFiles = List.generate(
        newPhotoBytes.length,
        (i) => _createImageMultipartFile(
          newPhotoBytes[i],
          i < newPhotoMimeTypes.length ? newPhotoMimeTypes[i] : null,
        ),
      );

      response = await apiClient.patchMultipart(
        '/user/dresses/$dressId',
        fields,
        multipartFiles,
        invalidateCacheKeys: [CacheKeys.dresses, CacheKeys.dress(dressId), '*/dresses*'],
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
      throw NetworkException('Network error updating dress', details: e.toString());
    }
  }

  Future<void> deleteDress(int dressId) async {
    try {
      http.Response response = await apiClient.delete(
        '/user/dresses/$dressId',
        {},
        invalidateCacheKeys: [CacheKeys.dresses, CacheKeys.dress(dressId), '*/dresses*'],
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

  Future<List<BookedRange>> getPublicDressBookings(int dressId) async {
    try {
      final response = await apiClient.get(
        '/dresses/$dressId/bookings',
        cacheKey: 'public_bookings_$dressId',
        cacheDuration: CacheDurations.short,
      );

      if (response.statusCode != HttpStatus.ok) {
        throw AppException(extractErrorMessage(response.body));
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((b) => BookedRange.fromJson(b as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching availability', details: e.toString());
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

  Future<Map<String, dynamic>> selfBook({
    required int dressId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await apiClient.post(
        '/dresses/$dressId/book',
        {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
        invalidateCacheKeys: ['public_bookings_$dressId'],
      );

      if (response.statusCode == HttpStatus.conflict) {
        throw AppException(extractErrorMessage(response.body), details: response.body);
      }
      if (response.statusCode != HttpStatus.created) {
        throw AppException(extractErrorMessage(response.body), details: response.body);
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error while creating booking', details: e.toString());
    }
  }

  Future<PaginatedResponse<Listing>> getPublicDresses({
    Map<String, dynamic>? allQueries,
  }) async {
    try {
      final response = await apiClient.get(
        '/dresses',
        cacheKey: CacheKeys.buildCacheKey('/dresses', queryParameters: allQueries),
        cacheDuration: CacheDurations.short,
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

  Future<Listing> getPublicDressById(int dressId) async {
    try {
      final response = await apiClient.get(
        '/dresses/$dressId',
        cacheKey: CacheKeys.listing(dressId),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException(extractErrorMessage(response.body));
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        return Listing.fromJsonString(response.body);
      } catch (e) {
        throw DataParseException('Failed to parse dress data', details: e.toString());
      }
    } catch (e) {
      if (e is NotFoundException || e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching dress', details: e.toString());
    }
  }

  Future<List<ListingAttribute>> getDressAttributes() async {
    try {
      final response = await apiClient.get(
        '/dresses/attributes',
        cacheKey: CacheKeys.dressAttribute,
        cacheDuration: CacheDurations.long,
      );

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          extractErrorMessage(response.body),
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        final List<dynamic> body = json.decode(response.body) as List<dynamic>;

        return body
            .map(
              (item) => ListingAttribute.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        throw DataParseException('Failed to parse dress attributes', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching dress attributes', details: e.toString());
    }
  }

  Future<List<RentalBooking>> getAllUserBookings() async {
    try {
      final response = await apiClient.get(
        '/user/dress-bookings',
        cacheKey: CacheKeys.userBookings,
        cacheDuration: CacheDurations.short,
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
      throw NetworkException('Network error fetching user bookings', details: e.toString());
    }
  }

  Future<List<UpcomingBooking>> getMyBookings() async {
    try {
      final response = await apiClient.get(
        '/user/my-bookings',
        cacheKey: CacheKeys.myBookings,
        cacheDuration: CacheDurations.short,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((b) => UpcomingBooking.fromJson(b as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException('Invalid response format', details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException('Network error fetching my bookings', details: e.toString());
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
