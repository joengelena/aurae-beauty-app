import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/models/pagination.dart';
import 'package:motorix_app/utils/utils.dart';

class ListingsServices {
  static final ApiClient apiClient = ApiClient();

  Future<Listing> getListing(int listingId) async {
    try {
      http.Response response = await apiClient.get('/listings/$listingId');

      if (response.statusCode == HttpStatus.notFound) {
        final errorMessage = extractErrorMessage(response.body);
        throw NotFoundException(errorMessage);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        return Listing.fromJsonString(response.body);
      } catch (e) {
        throw DataParseException(
          'Failed to parse listing data',
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
        'Network error getting listing',
        details: e.toString(),
      );
    }
  }

  Future<PaginatedResponse<Listing>> getAllListings({
    Map<String, dynamic>? allQueries,
  }) async {
    try {
      http.Response response = await apiClient.get(
        '/listings',
        queryParameters: allQueries,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
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
        throw DataParseException(
          'Failed to parse listings data',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error getting listings',
        details: e.toString(),
      );
    }
  }

  Future<List<ListingAttribute>> getListingAttributes() async {
    try {
      http.Response response = await apiClient.get('/listings/attributes');

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
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
        throw DataParseException(
          'Failed to parse listing attributes',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error getting listing attributes',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> postListing(
    Map<String, Object> listingFields,
    List<http.MultipartFile> images,
  ) async {
    try {
      final Map<String, String> payload = Map.fromEntries(
        listingFields.entries
            .where((e) => e.value.toString().isNotEmpty)
            .map((e) {
          return MapEntry(e.key, e.value.toString());
        }),
      );

      http.Response response = await apiClient.postMultipart(
        '/listings',
        payload,
        images,
      );

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      try {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        throw DataParseException(
          'Failed to parse listing response',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error posting listing',
        details: e.toString(),
      );
    }
  }

  Future<void> patchListing(
    int listingId,
    Map<String, Object> listingFields,
  ) async {
    try {
      final Map<String, dynamic> payload = Map.fromEntries(
        listingFields.entries.map((e) {
          return MapEntry(e.key, e.value);
        }),
      );

      http.Response response = await apiClient.patch(
        '/listings/$listingId',
        payload,
      );

      if (response.statusCode == HttpStatus.notFound) {
        final errorMessage = extractErrorMessage(response.body);
        throw NotFoundException(errorMessage);
      }

      if (response.statusCode == HttpStatus.forbidden) {
        final errorMessage = extractErrorMessage(response.body);
        throw ForbiddenException(errorMessage);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is NotFoundException ||
          e is ForbiddenException ||
          e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        'Network error updating listing',
        details: e.toString(),
      );
    }
  }

  Future<void> deleteListing(
    int listingId,
    Map<String, Object> listingFields,
  ) async {
    try {
      final Map<String, dynamic> payload = Map.fromEntries(
        listingFields.entries.map((e) {
          return MapEntry(e.key, e.value);
        }),
      );

      http.Response response = await apiClient.delete(
        '/listings/$listingId',
        payload,
      );

      if (response.statusCode == HttpStatus.notFound) {
        final errorMessage = extractErrorMessage(response.body);
        throw NotFoundException(errorMessage);
      }

      if (response.statusCode == HttpStatus.forbidden) {
        final errorMessage = extractErrorMessage(response.body);
        throw ForbiddenException(errorMessage);
      }

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is NotFoundException ||
          e is ForbiddenException ||
          e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        'Network error deleting listing',
        details: e.toString(),
      );
    }
  }

  Future<void> incrementViewCount(int listingId) async {
    try {
      http.Response response = await apiClient.post('/listings/$listingId/view', {});

      if (response.statusCode != HttpStatus.ok) {
        // Silently fail - view count is not critical
        return;
      }
    } catch (e) {
      // Silently fail - view count is not critical
      return;
    }
  }
}
