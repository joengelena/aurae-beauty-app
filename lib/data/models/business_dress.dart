class BusinessDress {
  final int id;
  final String userIdFk;
  final String? name;
  final String brand;
  final String style;
  final String listingType;
  final bool isPublic;
  final int? purchaseYear;
  final String? internalName;
  final String? color;
  final int? rentalCount;
  final DateTime? lastRentalDate;
  final String size;
  final int? purchasePrice;
  final int? rentalPricePerDay;
  final String condition;
  final String? dressPhotoUrl;
  final String? notes;
  final String? damageDescription;
  final List<String> damagePhotoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessDress({
    required this.id,
    required this.userIdFk,
    this.name,
    required this.brand,
    required this.style,
    this.listingType = 'rent',
    this.isPublic = false,
    this.purchaseYear,
    this.internalName,
    this.color,
    this.rentalCount,
    this.lastRentalDate,
    required this.size,
    this.purchasePrice,
    this.rentalPricePerDay,
    required this.condition,
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
      name: json['name'] as String?,
      brand: json['brand'] as String? ?? json['make'] as String? ?? '',
      style: json['style'] as String? ?? json['model'] as String? ?? '',
      listingType: json['listingType'] as String? ?? 'rent',
      isPublic: json['isPublic'] as bool? ?? false,
      purchaseYear: json['purchaseYear'] as int? ?? json['year'] as int?,
      internalName: json['internalName'] as String? ?? json['nickname'] as String?,
      color: json['color'] as String?,
      rentalCount: json['rentalCount'] as int? ?? 0,
      lastRentalDate: json['lastRentalDate'] != null
          ? DateTime.parse(json['lastRentalDate'] as String)
          : null,
      size: json['size'] as String? ?? 'M',
      purchasePrice: json['purchasePrice'] as int?,
      rentalPricePerDay: json['rentalPricePerDay'] as int?,
      condition: json['condition'] as String? ?? 'Excellent',
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
      'name': name,
      'brand': brand,
      'style': style,
      'listingType': listingType,
      'isPublic': isPublic,
      'purchaseYear': purchaseYear,
      'internalName': internalName,
      'color': color,
      'rentalCount': rentalCount,
      'lastRentalDate': lastRentalDate?.toIso8601String(),
      'size': size,
      'purchasePrice': purchasePrice,
      'rentalPricePerDay': rentalPricePerDay,
      'condition': condition,
      'dressPhotoUrl': dressPhotoUrl,
      'notes': notes,
      'damageDescription': damageDescription,
      'damagePhotoUrls': damagePhotoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
