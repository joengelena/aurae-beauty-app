import 'dart:convert';

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day-$month-$year';
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

final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
