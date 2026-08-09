class Business {
  final int id;
  final String name;
  final String category;
  final DateTime createdAt;

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'dress_rental',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
