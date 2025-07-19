import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/data/models/listing_filter.dart';
import 'package:motorix_app/data/models/pagination.dart';

class ListingsServices {
  static final ApiClient apiClient = ApiClient();

  Future<PaginatedResponse<Listing>> getAllListings({
    Map<String, dynamic>? allQueries,
  }) async {
    http.Response response = await apiClient.get(
      '/listings',
      queryParameters: allQueries,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load listings: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;

    return PaginatedResponse<Listing>.fromJson(
      body,
      (json) => Listing.fromJson(json),
    );
  }

  Future<List<ListingFilter>> getListingFilters() async {
    http.Response response = await apiClient.get('/listings/filters');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load listings: ${response.statusCode} ${response.body}',
      );
    }

    final List<dynamic> body = json.decode(response.body) as List<dynamic>;

    return body
        .map((item) => ListingFilter.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> postListing(
    Map<String, Object> listingFields,
    List<http.MultipartFile> images,
  ) async {
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

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load listings: ${response.statusCode} ${response.body}',
      );
    }

    final List<dynamic> body = json.decode(response.body) as List<dynamic>;
  }
}
