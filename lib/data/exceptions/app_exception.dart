/// Base exception class for all application exceptions
class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(this.message, {this.details, this.stackTrace});

  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
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

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException ($statusCode): $message${details != null ? ' - $details' : ''}';
    }
    return super.toString();
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
