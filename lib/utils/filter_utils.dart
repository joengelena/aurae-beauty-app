import 'package:shine_app/utils/utils.dart';

/// Utility class for filter-related operations
/// Centralizes filter key mapping to avoid duplication across providers
class FilterUtils {
  /// Maps internal filter keys to API parameter names
  /// This ensures consistent naming between the app and API
  static const Map<String, String> filterKeyToApiParam = {
    'make': 'make',
    'location': 'location',
    'vehicle_condition': 'vehicleCondition',
    'fuel_type': 'fuelType',
    'body_type': 'bodyType',
    'drive_type': 'driveType',
    'transmission': 'transmission',
  };

  /// Converts filter map to API query parameters
  /// Handles both equal filters and range filters
  /// Excludes 'None' values and empty strings, maps keys to API parameter names
  ///
  /// Example:
  /// ```dart
  /// {'make': 'Toyota', 'location': 'None', 'fuel_type': 'Petrol', 'priceFrom': '10000'}
  /// // Returns: {'make': 'Toyota', 'fuelType': 'Petrol', 'priceFrom': '10000'}
  /// ```
  static Map<String, String> toApiQueryParams(Map<String, String> filters) {
    final result = <String, String>{};

    filters.forEach((key, value) {
      if (value.isEmpty || value == 'None') return;

      // Check if it's a range filter
      if (rangeFilterKeyToApiParam.containsKey(key)) {
        result[rangeFilterKeyToApiParam[key]!] = value;
      }
      // Check if it's an equal filter
      else if (filterKeyToApiParam.containsKey(key)) {
        result[filterKeyToApiParam[key]!] = value;
      }
    });

    return result;
  }

  /// User-friendly display names for filter keys
  static const Map<String, String> filterDisplayNames = {
    'make': 'Brand',
    'location': 'Location',
    'vehicle_condition': 'Condition',
    'fuel_type': 'Fabric',
    'body_type': 'Dress Style',
    'drive_type': 'Fit Type',
    'transmission': 'Fit',
    'price': 'Price',
    'year': 'Year',
  };

  /// Maps range filter keys to API parameter names
  static const Map<String, String> rangeFilterKeyToApiParam = {
    'priceFrom': 'priceFrom',
    'priceTo': 'priceTo',
    'yearFrom': 'yearFrom',
    'yearTo': 'yearTo',
  };

  /// Formats a range filter for display as a badge
  ///
  /// Examples:
  /// - "Price: $1000 - $5000"
  /// - "Price: $3000 - Any"
  /// - "Year: 2015 - 2020"
  /// - "Kms: 50,000 - 120,000"
  static String formatRangeFilterDisplay(
    String baseKey,
    String minValue,
    String maxValue,
  ) {
    // Get the display label and prefix
    String label = '';
    String prefix = '';

    switch (baseKey) {
      case 'price':
        label = 'Price';
        prefix = '\$';
        break;
      case 'year':
        label = 'Year';
        break;
    }

    // Format min and max with thousand separators for kilometers
    String formattedMin =
        minValue.isEmpty ? 'Any' : '$prefix$minValue';
    String formattedMax =
        maxValue.isEmpty ? 'Any' : '$prefix$maxValue';

    return '$label: $formattedMin - $formattedMax';
  }
}
