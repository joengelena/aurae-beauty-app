import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/utils/utils.dart';

class VehicleServices {
  static final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> addVehicle(
    Map<String, dynamic> vehicleData,
  ) async {
    try {
      http.Response response = await apiClient.post(
        '/user/vehicles',
        vehicleData,
      );

      if (response.statusCode != HttpStatus.created) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        throw DataParseException(
          'Invalid response format',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error while adding vehicle',
        details: e.toString(),
      );
    }
  }

  Future<List<UserVehicle>> getAllVehicles() async {
    try {
      http.Response response = await apiClient.get('/user/vehicles');

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((vehicle) => UserVehicle.fromJson(vehicle as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw DataParseException(
          'Invalid response format',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error while fetching vehicles',
        details: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getVehicleById(int id) async {
    try {
      http.Response response = await apiClient.get('/user/vehicles/$id');

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['vehicle'] as Map<String, dynamic>;
      } catch (e) {
        throw DataParseException(
          'Invalid response format',
          details: e.toString(),
        );
      }
    } catch (e) {
      if (e is AppException || e is DataParseException) rethrow;
      throw NetworkException(
        'Network error while fetching vehicle',
        details: e.toString(),
      );
    }
  }
}
