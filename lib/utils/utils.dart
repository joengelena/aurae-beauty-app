import 'dart:convert';
import 'package:intl/intl.dart';

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
  return DateFormat('d MMM yyyy').format(date);
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
/// Pull the written message out of an error response.
///
/// Falls back to [fallback] rather than to the raw body.
/// The body of a failed request is not reliably ours — it can be a proxy's HTML
/// error page, a stack trace, or a socket error — and handing any of that to
/// someone as an explanation is worse than saying nothing. Callers supply their
/// own wording for that case.
String extractErrorMessage(
  String responseBody, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  try {
    final decoded = json.decode(responseBody);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
  } catch (_) {
    // Not JSON. Nothing quotable in here.
  }
  return fallback;
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

/// Move a calendar date by whole days.
///
/// Not `date.add(Duration(days: n))`. A Duration is a fixed number of hours, so
/// across a daylight-saving change the result lands at 23:00 or 01:00 rather
/// than midnight — and every date comparison in the app normalises to midnight
/// first, so the day silently shifts by one. New Zealand switches in late
/// September and early April, both inside wedding season.
///
/// The DateTime constructor rolls day overflow into the next month on its own
/// (day 32 becomes the 1st) and always returns local midnight.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);
