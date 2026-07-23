import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shine_app/data/api_client.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/cart_item.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/utils.dart';

class CartServices {
  static final ApiClient apiClient = ApiClient();

  Future<List<CartItem>> getCart() async {
    try {
      http.Response response = await apiClient.get(
        CacheKeys.userCart,
        cacheKey: CacheKeys.userCart,
        cacheDuration: CacheDurations.short,
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
        final List<dynamic> body = json.decode(response.body) as List<dynamic>;

        return body.map((item) => CartItem.fromJson(item)).toList();
      } catch (e) {
        throw DataParseException(
          'Failed to parse cart data',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) {
        rethrow;
      }
      throw NetworkException(
        'Network error getting cart',
        details: e.toString(),
      );
    }
  }

  Future<void> addToCart({
    required int dressId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = await apiClient.getUserId();

      if (userId == null) {
        throw UnauthenticatedException('User not signed in');
      }

      http.Response response = await apiClient.post(
        CacheKeys.userCart,
        {
          'dressId': dressId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
        invalidateCacheKeys: [CacheKeys.userCart],
      );

      if (response.statusCode != HttpStatus.created) {
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
        'Network error adding to cart',
        details: e.toString(),
      );
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      final userId = await apiClient.getUserId();

      if (userId == null) {
        throw UnauthenticatedException('User not signed in');
      }

      http.Response response = await apiClient.delete(
        '${CacheKeys.userCart}/$cartItemId',
        {},
        invalidateCacheKeys: [CacheKeys.userCart],
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
        'Network error removing from cart',
        details: e.toString(),
      );
    }
  }
}
