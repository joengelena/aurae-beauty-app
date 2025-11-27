import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/utils/utils.dart';

class VehicleServices {
  static final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> addVehicle(
    Map<String, dynamic> vehicleData, {
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      http.Response response;

      // If image is provided, use multipart/form-data
      if (imageBytes != null) {
        // Convert all fields to String for multipart request
        final fields = <String, String>{};
        vehicleData.forEach((key, value) {
          fields[key] = value.toString();
        });

        // Parse MIME type (e.g., "image/jpeg" -> type: "image", subtype: "jpeg")
        final mimeType = imageMimeType ?? 'image/jpeg';
        final mimeTypeParts = mimeType.split('/');
        final contentType = MediaType(
          mimeTypeParts[0],
          mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'jpeg',
        );

        // Create multipart file from image bytes with proper content type
        final multipartFile = http.MultipartFile.fromBytes(
          'image', // Field name expected by backend
          imageBytes,
          filename: 'vehicle_image.jpg',
          contentType: contentType,
        );

        response = await apiClient.postMultipart('/user/vehicles', fields, [
          multipartFile,
        ]);
      } else {
        // If no image, send as JSON (backend allows optional image)
        response = await apiClient.post('/user/vehicles', vehicleData);
      }

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
            .map(
              (vehicle) =>
                  UserVehicle.fromJson(vehicle as Map<String, dynamic>),
            )
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
        'Network error while fetching vehicle',
        details: e.toString(),
      );
    }
  }

  Future<void> updateVehicle(
    int vehicleId,
    Map<String, Object> vehicleFields,
  ) async {
    try {
      final Map<String, dynamic> payload = Map.fromEntries(
        vehicleFields.entries.map((e) {
          return MapEntry(e.key, e.value);
        }),
      );

      http.Response response = await apiClient.patch(
        '/user/vehicles/$vehicleId',
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
        'Network error updating vehicle',
        details: e.toString(),
      );
    }
  }

  Future<void> deleteVehicle(
    int vehicleId,
    Map<String, Object> vehicleFields,
  ) async {
    try {
      final Map<String, dynamic> payload = Map.fromEntries(
        vehicleFields.entries.map((e) {
          return MapEntry(e.key, e.value);
        }),
      );

      http.Response response = await apiClient.delete(
        '/user/vehicles/$vehicleId',
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
        'Network error deleting vehicle',
        details: e.toString(),
      );
    }
  }
}
