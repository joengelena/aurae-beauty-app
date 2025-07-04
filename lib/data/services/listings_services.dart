import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/listing.dart';
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
}
