import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/models/pagination.dart';

class ListingsServices {
  static final ApiClient apiClient = ApiClient();

  Future<Listing> getListing(int listingId) async {
    try {
      http.Response response = await apiClient.get('/listings/$listingId');

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException('Listing not found with ID: $listingId');
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          'Failed to load listing',
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
        throw NetworkException(
          'Failed to load listings',
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
        throw NetworkException(
          'Failed to get listing attributes',
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
        listingFields.entries.map((e) {
          return MapEntry(e.key, e.value.toString());
        }),
      );

      http.Response response = await apiClient.postMultipart(
        '/listings',
        payload,
        images,
      );

      if (response.statusCode != HttpStatus.created) {
        throw NetworkException(
          'Failed to post listing',
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
}
