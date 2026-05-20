class BusinessDress {
  final int id;
  final String userIdFk;
  final String brand;
  final String style;
  final int purchaseYear;
  final String? internalName;
  final String? color;
  final int? rentalCount;
  final DateTime? lastRentalDate;
  final String size;
  final int? purchasePrice;
  final String condition;
  final String insuranceExpiryDate;
  final String insuranceProvider;
  final String? dressPhotoUrl;
  final String? notes;
  final String? damageDescription;
  final List<String> damagePhotoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessDress({
    required this.id,
    required this.userIdFk,
    required this.brand,
    required this.style,
    required this.purchaseYear,
    this.internalName,
    this.color,
    this.rentalCount,
    this.lastRentalDate,
    required this.size,
    this.purchasePrice,
    required this.condition,
    required this.insuranceExpiryDate,
    required this.insuranceProvider,
    this.dressPhotoUrl,
    this.notes,
    this.damageDescription,
    this.damagePhotoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessDress.fromJson(Map<String, dynamic> json) {
    return BusinessDress(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      brand: json['brand'] as String? ?? json['make'] as String,
      style: json['style'] as String? ?? json['model'] as String,
      purchaseYear: json['purchaseYear'] as int? ?? json['year'] as int,
      internalName: json['internalName'] as String? ?? json['nickname'] as String?,
      color: json['color'] as String?,
      rentalCount: json['rentalCount'] as int? ?? 0,
      lastRentalDate: json['lastRentalDate'] != null
          ? DateTime.parse(json['lastRentalDate'] as String)
          : null,
      size: json['size'] as String? ?? 'M',
      purchasePrice: json['purchasePrice'] as int?,
      condition: json['condition'] as String? ?? 'Excellent',
      insuranceExpiryDate: json['insuranceExpiryDate'] as String,
      insuranceProvider: json['insuranceProvider'] as String,
      dressPhotoUrl: json['dressPhotoUrl'] as String? ?? json['vehiclePhotoUrl'] as String?,
      notes: json['notes'] as String?,
      damageDescription: json['damageDescription'] as String?,
      damagePhotoUrls: (json['damagePhotoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIdFk': userIdFk,
      'brand': brand,
      'style': style,
      'purchaseYear': purchaseYear,
      'internalName': internalName,
      'color': color,
      'rentalCount': rentalCount,
      'lastRentalDate': lastRentalDate?.toIso8601String(),
      'size': size,
      'purchasePrice': purchasePrice,
      'condition': condition,
      'insuranceExpiryDate': insuranceExpiryDate,
      'insuranceProvider': insuranceProvider,
      'dressPhotoUrl': dressPhotoUrl,
      'notes': notes,
      'damageDescription': damageDescription,
      'damagePhotoUrls': damagePhotoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
