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
import 'package:shine_app/data/models/dress_damage_incident.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/utils.dart';

class DressServices {
  static final ApiClient apiClient = ApiClient();

  /// Everything a booking add/update/delete can make stale: the dress's own
  /// booking list, the wardrobe-wide schedule, the renter's My Bookings, the
  /// public availability calendar, and the pending-request badge counts
  /// carried on the dress list and dress detail.
  static List<String> _bookingChangeCacheKeys(int dressId) => [
        CacheKeys.dressBookings(dressId),
        CacheKeys.userBookings,
        CacheKeys.myBookings,
        CacheKeys.publicDressBookings(dressId),
        CacheKeys.dresses,
        CacheKeys.dress(dressId),
      ];

  /// A damage incident change alters the dress's incident lists (owner and
  /// public) and the unresolved-damage badge counts on the dress list/detail.
  static List<String> _damageChangeCacheKeys(int dressId) => [
        CacheKeys.dressDamageIncidents(dressId),
        CacheKeys.publicDamageIncidents(dressId),
        CacheKeys.dresses,
        CacheKeys.dress(dressId),
      ];

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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while adding that dress. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading your dresses. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading that dress. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> updateDress(
    int dressId,
    Map<String, Object> dressFields, {
    List<Uint8List> newPhotoBytes = const [],
    List<String?> newPhotoMimeTypes = const [],
    // Null means "photos unchanged": the API only touches photos when
    // keepPhotoUrls is present, and an empty list deletes every photo.
    List<String>? keepPhotoUrls,
    List<DateTimeRange>? blockedDateRanges,
  }) async {
    try {
      http.Response response;

      final fields = <String, String>{};
      dressFields.forEach((key, value) {
        fields[key] = value is List ? json.encode(value) : value.toString();
      });
      if (keepPhotoUrls != null) {
        fields['keepPhotoUrls'] = json.encode(keepPhotoUrls);
      }
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
      throw NetworkException("Couldn't reach the server while updating that dress. Check your connection and try again.", details: e.toString());
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
      throw NetworkException("Couldn't reach the server while removing that dress. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading bookings. Check your connection and try again.", details: e.toString());
    }
  }

  Future<List<BookedRange>> getPublicDressBookings(int dressId) async {
    try {
      final response = await apiClient.get(
        '/dresses/$dressId/bookings',
        cacheKey: CacheKeys.publicDressBookings(dressId),
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading availability. Check your connection and try again.", details: e.toString());
    }
  }

  Future<List<DressDamageIncident>> getPublicDamageIncidents(int dressId) async {
    try {
      final response = await apiClient.get(
        '/dresses/$dressId/damage-incidents',
        cacheKey: CacheKeys.publicDamageIncidents(dressId),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        throw AppException(extractErrorMessage(response.body));
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((i) => DressDamageIncident.fromJson(i as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading damage reports. Check your connection and try again.", details: e.toString());
    }
  }

  Future<Map<String, dynamic>> addBooking(Map<String, dynamic> bookingData) async {
    try {
      final dressId = bookingData['dressIdFk'];

      http.Response response = await apiClient.post(
        '/user/dress-bookings',
        bookingData,
        invalidateCacheKeys: _bookingChangeCacheKeys(dressId),
      );

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while saving that booking. Check your connection and try again.", details: e.toString());
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
        invalidateCacheKeys: [
          CacheKeys.publicDressBookings(dressId),
          CacheKeys.myBookings,
          CacheKeys.userCart,
        ],
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while creating that booking. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading your dresses. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is NotFoundException || e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading that dress. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading dress details. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading those bookings. Check your connection and try again.", details: e.toString());
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
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading your bookings. Check your connection and try again.", details: e.toString());
    }
  }

  /// [dressId] narrows the availability invalidation to that dress; without
  /// it every dress's public availability is cleared.
  Future<void> cancelMyBooking(int bookingId, {int? dressId}) async {
    try {
      final response = await apiClient.patch(
        '/user/my-bookings/$bookingId/cancel',
        {},
        invalidateCacheKeys: [
          CacheKeys.myBookings,
          CacheKeys.userCart,
          dressId != null
              ? CacheKeys.publicDressBookings(dressId)
              : CacheKeys.allPublicDressBookings,
        ],
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
      throw NetworkException("Couldn't reach the server while cancelling that booking. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> updateBooking(
    int bookingId,
    int dressId,
    Map<String, dynamic> updates,
  ) async {
    try {
      http.Response response = await apiClient.patch(
        '/user/dress-bookings/$bookingId',
        updates,
        invalidateCacheKeys: _bookingChangeCacheKeys(dressId),
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
      throw NetworkException("Couldn't reach the server while updating that booking. Check your connection and try again.", details: e.toString());
    }
  }

  Future<List<DressDamageIncident>> getDamageIncidents(int dressId) async {
    try {
      final response = await apiClient.get(
        '/user/dresses/$dressId/damage-incidents',
        cacheKey: CacheKeys.dressDamageIncidents(dressId),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((i) => DressDamageIncident.fromJson(i as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException("The server sent something we couldn't read. Please try again.", details: e.toString());
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while loading damage reports. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> addDamageIncident(
    int dressId,
    Map<String, dynamic> incidentData, {
    List<Uint8List> photoBytes = const [],
    List<String?> photoMimeTypes = const [],
  }) async {
    try {
      http.Response response;

      if (photoBytes.isNotEmpty) {
        final fields = <String, String>{};
        incidentData.forEach((key, value) => fields[key] = value.toString());

        final multipartFiles = List.generate(
          photoBytes.length,
          (i) => _createImageMultipartFile(
            photoBytes[i],
            i < photoMimeTypes.length ? photoMimeTypes[i] : null,
          ),
        );

        response = await apiClient.postMultipart(
          '/user/dresses/$dressId/damage-incidents',
          fields,
          multipartFiles,
          invalidateCacheKeys: _damageChangeCacheKeys(dressId),
        );
      } else {
        response = await apiClient.post(
          '/user/dresses/$dressId/damage-incidents',
          incidentData,
          invalidateCacheKeys: _damageChangeCacheKeys(dressId),
        );
      }

      if (response.statusCode != HttpStatus.created) {
        throw AppException(extractErrorMessage(response.body), details: response.body);
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException("Couldn't reach the server while saving that damage report. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> updateDamageIncident(
    int dressId,
    int incidentId,
    Map<String, dynamic> updates, {
    List<Uint8List> newPhotoBytes = const [],
    List<String?> newPhotoMimeTypes = const [],
    // Null means "photos unchanged" (e.g. toggling resolved); an empty list
    // deletes every photo on the incident.
    List<String>? keepPhotoUrls,
  }) async {
    try {
      final fields = <String, String>{};
      updates.forEach((key, value) => fields[key] = value.toString());
      if (keepPhotoUrls != null) {
        fields['keepPhotoUrls'] = json.encode(keepPhotoUrls);
      }

      final multipartFiles = List.generate(
        newPhotoBytes.length,
        (i) => _createImageMultipartFile(
          newPhotoBytes[i],
          i < newPhotoMimeTypes.length ? newPhotoMimeTypes[i] : null,
        ),
      );

      final response = await apiClient.patchMultipart(
        '/user/dresses/$dressId/damage-incidents/$incidentId',
        fields,
        multipartFiles,
        invalidateCacheKeys: _damageChangeCacheKeys(dressId),
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
      throw NetworkException("Couldn't reach the server while updating that damage report. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> deleteDamageIncident(int dressId, int incidentId) async {
    try {
      final response = await apiClient.delete(
        '/user/dresses/$dressId/damage-incidents/$incidentId',
        {},
        invalidateCacheKeys: _damageChangeCacheKeys(dressId),
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
      throw NetworkException("Couldn't reach the server while removing that damage report. Check your connection and try again.", details: e.toString());
    }
  }

  Future<void> deleteBooking(int bookingId, int dressId) async {
    try {
      http.Response response = await apiClient.delete(
        '/user/dress-bookings/$bookingId',
        {},
        invalidateCacheKeys: _bookingChangeCacheKeys(dressId),
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
      throw NetworkException("Couldn't reach the server while removing that booking. Check your connection and try again.", details: e.toString());
    }
  }
}
