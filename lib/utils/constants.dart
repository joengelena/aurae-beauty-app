/// App-wide constants
class AppConstants {
  /// Standard aspect ratio for listing images (4:3)
  /// This ensures consistent image sizing across the app
  static const double listingImageAspectRatio = 4 / 3;
  static const double cardShadowElevation = 3;

  /// Maximum width for content containers
  static const double contentMaxWidth = 600;

  /// Screen width breakpoint for 2-column grid layout
  static const double twoColumnBreakpoint = 550;

  /// Standard spacing values
  static const double spacingSmall = 8;
  static const double spacingMedium = 12;
  static const double spacingLarge = 16;
  static const double spacingExtraLarge = 64;

  static const Duration snackBarDurationSeconds = Duration(seconds: 3);
}

/// HTTP cache duration constants
class CacheDurations {
  /// Short duration for frequently changing user-specific data
  static const Duration short = Duration(minutes: 5);

  /// Medium duration for public data that changes regularly
  static const Duration medium = Duration(minutes: 10);

  /// Long duration for static/configuration data
  static const Duration long = Duration(hours: 1);
}

/// HTTP cache key builders
/// Provides consistent cache key format across the app
class CacheKeys {
  /// Build cache key from path and query parameters
  /// This ensures different queries are cached separately
  /// Made static so services can build cache keys before calling get()
  static String buildCacheKey(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return path;
    }
    // Sort parameters to ensure consistent cache keys
    final sortedParams = Map.fromEntries(
      queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final queryString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$path?$queryString';
  }

  // Listings
  static const String listingAttribute = '/listings/attributes';
  static String listings(Map<String, dynamic>? queryParameters) =>
      buildCacheKey('/listings', queryParameters: queryParameters);
  static String listing(int id) => '/listings/$id';
  static String allListingsCache = '*listings*';

  // User
  static String userDetails(String id) => '/users/$id';
  static const String userWatchlist = '/user/watchlist';

  // Vehicles
  static const String vehicles = '/user/vehicles';
  static String vehicle(int id) => '/user/vehicles/$id';
  static String vehicleServices(int vehicleId) =>
      '/user/vehicles/$vehicleId/services';
}
