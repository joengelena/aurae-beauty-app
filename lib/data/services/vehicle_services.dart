import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/data/models/vehicle_service.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:motorix_app/utils/utils.dart';

class VehicleServices {
  static final ApiClient apiClient = ApiClient();

  /// Creates a multipart file from image bytes with proper content type and filename.
  ///
  /// Generates appropriate filename based on MIME type:
  /// - 'image/jpeg' or 'image/jpg' -> 'vehicle_image.jpg'
  /// - 'image/png' -> 'vehicle_image.png'
  /// - 'image/webp' -> 'vehicle_image.webp'
  /// - null or invalid -> defaults to 'vehicle_image.jpg'
  static http.MultipartFile _createImageMultipartFile(
    Uint8List imageBytes,
    String? mimeType,
  ) {
    // Default to JPEG if no MIME type provided
    final resolvedMimeType = mimeType ?? 'image/jpeg';
    final mimeTypeParts = resolvedMimeType.split('/');

    // Extract file extension from MIME type (e.g., "image/jpeg" -> "jpg")
    String extension = 'jpg';
    if (mimeTypeParts.length > 1) {
      extension = mimeTypeParts[1].toLowerCase();
      // Handle special cases
      if (extension == 'jpeg') extension = 'jpg';
    }

    final contentType = MediaType(
      mimeTypeParts[0],
      mimeTypeParts.length > 1 ? mimeTypeParts[1] : 'jpeg',
    );

    return http.MultipartFile.fromBytes(
      'image', // Field name expected by backend
      imageBytes,
      filename: 'vehicle_image.$extension',
      contentType: contentType,
    );
  }

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

        // Create multipart file from image bytes
        final multipartFile = _createImageMultipartFile(
          imageBytes,
          imageMimeType,
        );

        response = await apiClient.postMultipart(
          '/user/vehicles',
          fields,
          [multipartFile],
          invalidateCacheKeys: [CacheKeys.vehicles],
        );
      } else {
        // If no image, send as JSON (backend allows optional image)
        response = await apiClient.post(
          '/user/vehicles',
          vehicleData,
          invalidateCacheKeys: [CacheKeys.vehicles],
        );
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
      http.Response response = await apiClient.get(
        '/user/vehicles',
        cacheKey: CacheKeys.vehicles,
        cacheDuration: CacheDurations.medium,
      );

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

  Future<UserVehicle> getVehicleById(int id) async {
    try {
      http.Response response = await apiClient.get(
        '/user/vehicles/$id',
        cacheKey: CacheKeys.vehicle(id),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UserVehicle.fromJson(data);
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
    Map<String, Object> vehicleFields, {
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      http.Response response;

      // If image is provided, use multipart/form-data
      if (imageBytes != null) {
        // Convert all fields to String for multipart request
        final fields = <String, String>{};
        vehicleFields.forEach((key, value) {
          fields[key] = value.toString();
        });

        // Create multipart file from image bytes
        final multipartFile = _createImageMultipartFile(
          imageBytes,
          imageMimeType,
        );

        response = await apiClient.patchMultipart(
          '/user/vehicles/$vehicleId',
          fields,
          [multipartFile],
          invalidateCacheKeys: [
            CacheKeys.vehicles,
            CacheKeys.vehicle(vehicleId),
          ],
        );
      } else {
        // If no image, send as JSON (same as before)
        final Map<String, dynamic> payload = Map.fromEntries(
          vehicleFields.entries.map((e) {
            return MapEntry(e.key, e.value);
          }),
        );

        response = await apiClient.patch(
          '/user/vehicles/$vehicleId',
          payload,
          invalidateCacheKeys: [
            CacheKeys.vehicles,
            CacheKeys.vehicle(vehicleId),
          ],
        );
      }

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
        invalidateCacheKeys: [
          CacheKeys.vehicles, // Garage list no longer contains vehicle
          CacheKeys.vehicle(vehicleId), // Vehicle detail should show 404
        ],
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

  Future<Map<String, dynamic>> addServiceRecord(
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final vehicleId = serviceData['vehicleIdFk'];

      http.Response response = await apiClient.post(
        '/user/vehicle-services',
        serviceData,
        invalidateCacheKeys: [CacheKeys.vehicleServices(vehicleId)],
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
        'Network error while adding service record',
        details: e.toString(),
      );
    }
  }

  Future<List<VehicleService>> getServicesByVehicleId(int vehicleId) async {
    try {
      http.Response response = await apiClient.get(
        '/user/vehicles/$vehicleId/services',
        cacheKey: CacheKeys.vehicleServices(vehicleId),
        cacheDuration: CacheDurations.medium,
      );

      if (response.statusCode != HttpStatus.ok) {
        final errorMessage = extractErrorMessage(response.body);
        throw AppException(errorMessage, details: response.body);
      }

      try {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map(
              (service) =>
                  VehicleService.fromJson(service as Map<String, dynamic>),
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
        'Network error while fetching service records',
        details: e.toString(),
      );
    }
  }

  Future<void> deleteService(int serviceId, int vehicleId) async {
    try {
      http.Response response = await apiClient.delete(
        '/user/vehicle-services/$serviceId',
        {},
        invalidateCacheKeys: [CacheKeys.vehicleServices(vehicleId)],
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
        'Network error deleting service record',
        details: e.toString(),
      );
    }
  }
}
