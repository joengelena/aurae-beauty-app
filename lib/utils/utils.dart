import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';

/// Formats a number with thousand separators
///
/// Example: 120000 → "120,000"
String formatNumber(String value) {
  final intValue = int.tryParse(value);
  if (intValue == null) return value;

  return intValue.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day-$month-$year';
}

String formatVehicleName(UserVehicle vehicle) {
  return '${vehicle.year} ${vehicle.make} ${vehicle.model}';
}

String formatKilometers(int km) {
  final formatter = NumberFormat('#,###');
  return '${formatter.format(km)} km';
}

String formatPrice(int price) {
  final formatter = NumberFormat('#,###');
  return '\$${formatter.format(price)}';
}

/// Extracts error message from API response body
/// Attempts to parse JSON and extract the 'message' field
/// Returns the original body if parsing fails
String extractErrorMessage(String responseBody) {
  try {
    final errorData = json.decode(responseBody) as Map<String, dynamic>;
    return errorData['message'] as String? ?? responseBody;
  } catch (e) {
    return responseBody;
  }
}

/// Extracts user ID from a JWT token
/// Returns the 'sub' claim from the token payload, or null if extraction fails
String? extractUserIdFromJWT(String token) {
  try {
    // JWT is formatted as: header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Decode the payload (second part)
    String payload = parts[1];

    // Normalize base64 padding
    switch (payload.length % 4) {
      case 2:
        payload += '==';
        break;
      case 3:
        payload += '=';
        break;
    }

    final decoded = utf8.decode(base64.decode(payload));
    final Map<String, dynamic> payloadMap = json.decode(decoded);
    return payloadMap['sub'] as String?;
  } catch (e) {
    return null;
  }
}

final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
