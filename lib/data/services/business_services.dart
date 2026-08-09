import 'dart:convert';
import 'dart:io';
import 'package:shine_app/data/api_client.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/utils.dart';

class BusinessServices {
  static final ApiClient apiClient = ApiClient();

  Future<({Business? business, String? role})> getMyBusiness() async {
    try {
      final response = await apiClient.get(
        '/business/mine',
        cacheKey: CacheKeys.myBusiness,
        cacheDuration: CacheDurations.short,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final businessJson = data['business'] as Map<String, dynamic>?;
        return (
          business: businessJson != null ? Business.fromJson(businessJson) : null,
          role: data['role'] as String?,
        );
      } catch (e) {
        throw DataParseException('Invalid business response format', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error loading your business', details: e.toString());
    }
  }

  Future<Business> createBusiness(String name) async {
    try {
      final response = await apiClient.post(
        '/business',
        {'name': name},
        invalidateCacheKeys: [CacheKeys.myBusiness],
      );

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Business.fromJson(data['business'] as Map<String, dynamic>);
      } catch (e) {
        throw DataParseException('Invalid business response format', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error creating business', details: e.toString());
    }
  }

  Future<String> generateInviteCode(int businessId, String role) async {
    try {
      final response = await apiClient.post('/business/$businessId/invites', {
        'role': role,
      });

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['code'] as String;
      } catch (e) {
        throw DataParseException('Invalid invite response format', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error creating invite', details: e.toString());
    }
  }

  Future<({Business business, String role})> redeemInviteCode(String code) async {
    try {
      final response = await apiClient.post(
        '/business/invites/redeem',
        {'code': code},
        invalidateCacheKeys: [CacheKeys.myBusiness],
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw NetworkException(errorMessage, statusCode: response.statusCode, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return (
          business: Business.fromJson(data['business'] as Map<String, dynamic>),
          role: data['role'] as String,
        );
      } catch (e) {
        throw DataParseException('Invalid invite response format', details: e.toString());
      }
    } catch (e) {
      if (e is NetworkException || e is DataParseException) rethrow;
      throw NetworkException('Network error redeeming invite', details: e.toString());
    }
  }
}
