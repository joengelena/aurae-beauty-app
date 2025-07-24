import 'dart:convert';

class ListingAttribute {
  final String name;
  final List<String> attributeValues;

  ListingAttribute({required this.name, required this.attributeValues});

  /// Creates a new Listing Filter from a JSON map.
  factory ListingAttribute.fromJson(Map<String, dynamic> json) {
    return ListingAttribute(
      name: json['name'] as String,
      attributeValues: List.from(jsonDecode(json['attributeValues'])),
    );
  }

  /// Convenience to parse directly from a JSON string.
  factory ListingAttribute.fromJsonString(String jsonString) =>
      ListingAttribute.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );
}
