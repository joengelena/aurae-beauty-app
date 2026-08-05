import 'dart:convert';

class Listing {
  final int id;
  final String userIdFk;
  final String status;
  final int viewCount;
  final String previewImgUrl;
  final List<dynamic> imageUrls;
  final String location;
  final String condition;
  final int pricePerDay;
  final DateTime uploadDate;
  final String description;
  final String? name;
  final String brand;
  final String style;
  final String size;
  // Every size this dress group is available in, when the Browse feed has
  // collapsed same-brand/style/owner size variants into one tile. Falls back
  // to [size] when the API doesn't return it (e.g. a single-size dress).
  final List<String> availableSizes;
  final String? color;
  final String? dressType;
  final String? fitNote;
  final List<String> recommendedSizes;
  final int? purchasePrice;
  final DateTime? availableFrom;
  final String listingType;
  final bool? isInWatchlist;

  Listing({
    required this.id,
    required this.userIdFk,
    required this.status,
    required this.viewCount,
    required this.previewImgUrl,
    required this.imageUrls,
    required this.location,
    required this.condition,
    required this.pricePerDay,
    required this.uploadDate,
    required this.description,
    this.name,
    required this.brand,
    required this.style,
    required this.size,
    this.availableSizes = const [],
    this.color,
    this.dressType,
    this.fitNote,
    this.recommendedSizes = const [],
    this.purchasePrice,
    this.availableFrom,
    this.listingType = 'rent',
    this.isInWatchlist,
  });

  factory Listing.fromJson(json) {
    return Listing(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      status: json['status'] as String? ?? 'active',
      viewCount: json['viewCount'] as int? ?? 0,
      previewImgUrl: json['previewImgUrl'] as String? ?? json['dressPhotoUrl'] as String? ?? '',
      imageUrls: json['imageUrls'] as List<dynamic>? ?? [],
      location: json['location'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      pricePerDay: json['pricePerDay'] as int? ?? json['rentalPricePerDay'] as int? ?? 0,
      uploadDate: DateTime.parse(json['uploadDate'] as String? ?? json['createdAt'] as String),
      description: json['description'] as String? ?? json['notes'] as String? ?? '',
      name: json['name'] as String?,
      brand: json['brand'] as String,
      style: json['style'] as String,
      size: json['size'] as String,
      availableSizes: (json['availableSizes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [json['size'] as String],
      color: json['color'] as String?,
      dressType: json['dressType'] as String?,
      fitNote: json['fitNote'] as String?,
      recommendedSizes: (json['recommendedSizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      purchasePrice: json['purchasePrice'] as int?,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'] as String)
          : null,
      listingType: json['listingType'] as String? ?? 'rent',
      isInWatchlist: json['isInWatchlist'] != null
          ? (json['isInWatchlist'] == 1 || json['isInWatchlist'] == true)
          : null,
    );
  }

  factory Listing.fromJsonString(String jsonString) =>
      Listing.fromJson(json.decode(jsonString));

  Listing copyWith({
    int? id,
    String? userIdFk,
    String? status,
    int? viewCount,
    String? previewImgUrl,
    List<dynamic>? imageUrls,
    String? location,
    String? condition,
    int? pricePerDay,
    DateTime? uploadDate,
    String? description,
    String? name,
    String? brand,
    String? style,
    String? size,
    List<String>? availableSizes,
    String? color,
    String? dressType,
    String? fitNote,
    List<String>? recommendedSizes,
    int? purchasePrice,
    DateTime? availableFrom,
    String? listingType,
    bool? isInWatchlist,
  }) {
    return Listing(
      id: id ?? this.id,
      userIdFk: userIdFk ?? this.userIdFk,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      previewImgUrl: previewImgUrl ?? this.previewImgUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      style: style ?? this.style,
      size: size ?? this.size,
      availableSizes: availableSizes ?? this.availableSizes,
      color: color ?? this.color,
      dressType: dressType ?? this.dressType,
      fitNote: fitNote ?? this.fitNote,
      recommendedSizes: recommendedSizes ?? this.recommendedSizes,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      availableFrom: availableFrom ?? this.availableFrom,
      listingType: listingType ?? this.listingType,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
    );
  }

  @override
  String toString() {
    return 'Listing(id: $id, userIdFk: $userIdFk, brand: $brand, style: $style, size: $size, pricePerDay: $pricePerDay)';
  }
}
