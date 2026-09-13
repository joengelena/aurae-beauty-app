/// Turn anything thrown into a sentence worth showing someone.
///
/// Our own exceptions already carry a written message, so they pass through.
/// Anything else — a raw Exception, a platform error, a parse failure — has a
/// developer's words in it, and the honest thing is to say something true and
/// general rather than hand a renter `FormatException: Unexpected character`.
///
/// [fallback] lets a caller say what was being attempted, so the generic case
/// still tells the person which thing didn't work.
String userMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is AppException) {
    final message = error.message.trim();
    if (message.isNotEmpty) return message;
  }
  return fallback;
}

/// Base exception class for all application exceptions
class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(this.message, {this.details, this.stackTrace});

  /// What to show a person.
  ///
  /// toString() is what the UI reaches for, so it returns the message alone.
  /// It used to append `details`, which services set to the raw response body —
  /// so a refused booking read "Those dates are no longer available:
  /// {"message":"Those dates are no longer available"}".
  ///
  /// Diagnostics have not gone anywhere; they moved to [diagnostic], which is
  /// what belongs in a log.
  @override
  String toString() => message;

  /// Everything known about the failure, for logs and bug reports. Never shown.
  String get diagnostic {
    final parts = <String>['$runtimeType: $message'];
    if (details != null) parts.add('details: $details');
    return parts.join(' | ');
  }
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException(super.message, {super.details, super.stackTrace});
}

/// Exception thrown when a network request fails
class NetworkException extends AppException {
  final int? statusCode;

  NetworkException(
    super.message, {
    this.statusCode,
    super.details,
    super.stackTrace,
  });

  /// Inherits the message-only toString. The status code is a fact about the
  /// transport, not something a renter can act on — it lives in [diagnostic].
  @override
  String get diagnostic {
    final parts = <String>['$runtimeType: $message'];
    if (statusCode != null) parts.add('status: $statusCode');
    if (details != null) parts.add('details: $details');
    return parts.join(' | ');
  }
}

/// Exception thrown when data parsing fails
class DataParseException extends AppException {
  DataParseException(super.message, {super.details, super.stackTrace});
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.details, super.stackTrace});
}

/// Exception thrown when user is not authenticated
class UnauthenticatedException extends AppException {
  UnauthenticatedException(
    super.message, {
    super.details,
    super.stackTrace,
  });
}

/// Exception thrown when user is not authorized to perform an action
class ForbiddenException extends AppException {
  ForbiddenException(super.message, {super.details, super.stackTrace});
}
