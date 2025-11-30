/// Base interface for providers that manage form data.
///
/// This interface enables form field widgets to work with any provider
/// that exposes a formData map, regardless of whether it's for listings,
/// vehicles, or other entities.
abstract class FormDataProvider {
  /// The map containing all form field values.
  ///
  /// Keys are field names, values are the user's input.
  /// Types can be String, int, or other primitives depending on the field.
  Map<String, Object> get formData;
}
