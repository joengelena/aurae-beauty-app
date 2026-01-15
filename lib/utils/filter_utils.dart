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
  /// Excludes 'None' values and maps keys to API parameter names
  ///
  /// Example:
  /// ```dart
  /// {'make': 'Toyota', 'location': 'None', 'fuel_type': 'Petrol'}
  /// // Returns: {'make': 'Toyota', 'fuelType': 'Petrol'}
  /// ```
  static Map<String, String> toApiQueryParams(
    Map<String, String> filters,
  ) {
    return Map.fromEntries(
      filters.entries
          .where((entry) =>
              entry.value != 'None' &&
              filterKeyToApiParam.containsKey(entry.key))
          .map((entry) => MapEntry(
                filterKeyToApiParam[entry.key]!,
                entry.value,
              )),
    );
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
  };
}
