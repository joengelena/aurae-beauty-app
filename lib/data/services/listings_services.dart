import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/models/preview_listing.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/models/pagination.dart';

class ListingsServices {
  static final ApiClient apiClient = ApiClient();

  Future<PaginatedResponse<PreviewListing>> getAllListings({
    Map<String, dynamic>? allQueries,
  }) async {
    http.Response response = await apiClient.get(
      '/listings',
      queryParameters: allQueries,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load listings');
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;

    return PaginatedResponse<PreviewListing>.fromJson(
      body,
      (json) => PreviewListing.fromJson(json),
    );
  }

  Future<List<ListingAttribute>> getListingAttributes() async {
    http.Response response = await apiClient.get('/listings/attributes');

    if (response.statusCode != 200) {
      throw Exception('Failed to get listing attributes');
    }

    final List<dynamic> body = json.decode(response.body) as List<dynamic>;

    return body
        .map((item) => ListingAttribute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ApiResponse<Map<String, dynamic>>> postListing(
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

    if (response.statusCode != HttpStatus.created) {
      return ApiResponse.failure('Failed to post list please try again later');
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;

    return ApiResponse.success(body);
  }
}
