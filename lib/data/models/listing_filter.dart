import 'dart:convert';

class ListingFilter {
  final String name;
  final List<String> filterValues;

  ListingFilter({required this.name, required this.filterValues});

  /// Creates a new Listing Filter from a JSON map.
  factory ListingFilter.fromJson(Map<String, dynamic> json) {
    return ListingFilter(
      name: json['name'] as String,
      filterValues: List.from(jsonDecode(json['filterValues'])),
    );
  }

  /// Convenience to parse directly from a JSON string.
  factory ListingFilter.fromJsonString(String jsonString) =>
      ListingFilter.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
