class CartItem {
  final int id;
  final int dressIdFk;
  final DateTime startDate;
  final DateTime endDate;
  final int pricePerDay;
  final DateTime createdAt;
  final String? name;
  final String brand;
  final String style;
  final String size;
  final String dressPhotoUrl;
  final String location;

  /// Whether these dates are still free. Recomputed server-side on every cart
  /// fetch, because a cart holds its dates over time and the dress can be taken
  /// in between. Defaults to true so an API that doesn't send it yet doesn't
  /// grey out the whole cart.
  final bool isAvailable;

  CartItem({
    required this.id,
    required this.dressIdFk,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.createdAt,
    this.name,
    required this.brand,
    required this.style,
    required this.size,
    required this.dressPhotoUrl,
    required this.location,
    this.isAvailable = true,
  });

  factory CartItem.fromJson(json) {
    return CartItem(
      id: json['id'] as int,
      dressIdFk: json['dressIdFk'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      pricePerDay: json['pricePerDay'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String?,
      brand: json['brand'] as String,
      style: json['style'] as String,
      size: json['size'] as String,
      dressPhotoUrl: json['dressPhotoUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  // A rental is a whole day that goes overnight, so a stay from the 23rd to
  // the 24th is one night, not two.
  int get nights => endDate.difference(startDate).inDays;

  int get totalPrice => nights * pricePerDay;
}
