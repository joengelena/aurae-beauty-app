import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/utils/utils.dart';

class WatchlistServices {
  static final ApiClient apiClient = ApiClient();

  Future<List<Listing>> getWatchlist() async {
    try {
      http.Response response = await apiClient.get('/user/watchlist');

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

        return body.map((item) => Listing.fromJson(item)).toList();
      } catch (e) {
        throw DataParseException(
          'Failed to parse watchlist data',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) {
        rethrow;
      }
      throw NetworkException(
        'Network error getting watchlist',
        details: e.toString(),
      );
    }
  }

  Future<void> addToWatchlist(int listingId) async {
    try {
      final userId = await apiClient.getUserId();

      if (userId == null) {
        throw UnauthenticatedException('User not signed in');
      }

      http.Response response = await apiClient.post(
        '/user/watchlist-add/$listingId',
        {},
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is UnauthenticatedException || e is NetworkException) rethrow;
      throw NetworkException(
        'Network error adding to watchlist',
        details: e.toString(),
      );
    }
  }

  Future<void> removeFromWatchlist(int listingId) async {
    try {
      final userId = await apiClient.getUserId();

      if (userId == null) {
        throw UnauthenticatedException('User not signed in');
      }

      http.Response response = await apiClient.delete(
        '/user/watchlist-remove/$listingId',
        {},
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(
          errorMessage,
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } catch (e) {
      if (e is UnauthenticatedException || e is NetworkException) rethrow;
      throw NetworkException(
        'Network error removing from watchlist',
        details: e.toString(),
      );
    }
  }
}
