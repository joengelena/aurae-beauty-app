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
    'cylinders': 'cylinders',
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
  static Map<String, String> toApiQueryParams(
    Map<String, String> filters,
  ) {
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
    'make': 'Make',
    'location': 'Location',
    'vehicle_condition': 'Condition',
    'fuel_type': 'Fuel',
    'body_type': 'Body style',
    'drive_type': 'Drive type',
    'transmission': 'Transmission',
    'cylinders': 'Cylinders',
    'price': 'Price',
    'year': 'Year',
    'kilometers': 'Kilometers',
  };

  /// Maps range filter keys to API parameter names
  static const Map<String, String> rangeFilterKeyToApiParam = {
    'priceFrom': 'priceFrom',
    'priceTo': 'priceTo',
    'yearFrom': 'yearFrom',
    'yearTo': 'yearTo',
    'kilometersFrom': 'kilometersFrom',
    'kilometersTo': 'kilometersTo',
  };
}
