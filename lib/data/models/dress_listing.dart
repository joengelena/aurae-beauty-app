import 'dart:convert';

class DressListing {
  final int id;
  final String userIdFk;
  final String status;
  final int viewCount;
  final String previewImgUrl;
  final List<dynamic> imageUrls;
  final String location;
  final String condition;
  final int rentalPricePerDay;
  final int? discountedPricePerDay;
  final DateTime uploadDate;
  final String description;
  final String brand;
  final String style;
  final String? season;
  final String fabricType;
  final String dressType;
  final String? color;
  final List<String> sizes;
  final String? length;
  final String? neckline;
  final String? sleeveType;
  final List<String>? occasions;
  final String? rentalDuration;
  final String? fitType;
  final bool? isInWatchlist;

  DressListing({
    required this.id,
    required this.userIdFk,
    required this.status,
    required this.viewCount,
    required this.previewImgUrl,
    required this.imageUrls,
    required this.location,
    required this.condition,
    required this.rentalPricePerDay,
    this.discountedPricePerDay,
    required this.uploadDate,
    required this.description,
    required this.brand,
    required this.style,
    this.season,
    required this.fabricType,
    required this.dressType,
    this.color,
    required this.sizes,
    this.length,
    this.neckline,
    this.sleeveType,
    this.occasions,
    this.rentalDuration,
    this.fitType,
    this.isInWatchlist,
  });

  factory DressListing.fromJson(json) {
    return DressListing(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      status: json['status'] as String,
      viewCount: json['viewCount'] as int,
      previewImgUrl: json['previewImgUrl'] as String,
      imageUrls: json['imageUrls'] as List<dynamic>,
      location: json['location'] as String,
      condition: json['condition'] as String? ?? json['vehicleCondition'] as String,
      rentalPricePerDay: json['rentalPricePerDay'] as int? ?? json['originalPrice'] as int,
      discountedPricePerDay: json['discountedPricePerDay'] as int? ?? json['discountedPrice'] as int?,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      description: json['description'] as String,
      brand: json['brand'] as String? ?? json['make'] as String,
      style: json['style'] as String? ?? json['model'] as String,
      season: json['season'] as String?,
      fabricType: json['fabricType'] as String? ?? json['fuelType'] as String? ?? '',
      dressType: json['dressType'] as String? ?? json['bodyType'] as String,
      color: json['color'] as String?,
      sizes: json['sizes'] != null
          ? List<String>.from(json['sizes'] as List)
          : [],
      length: json['length'] as String?,
      neckline: json['neckline'] as String?,
      sleeveType: json['sleeveType'] as String?,
      occasions: json['occasions'] != null
          ? List<String>.from(json['occasions'] as List)
          : null,
      rentalDuration: json['rentalDuration'] as String?,
      fitType: json['fitType'] as String? ?? json['transmission'] as String?,
      isInWatchlist: json['isInWatchlist'] != null
          ? (json['isInWatchlist'] == 1 || json['isInWatchlist'] == true)
          : null,
    );
  }

  factory DressListing.fromJsonString(String jsonString) =>
      DressListing.fromJson(json.decode(jsonString));

  DressListing copyWith({
    int? id,
    String? userIdFk,
    String? status,
    int? viewCount,
    String? previewImgUrl,
    List<dynamic>? imageUrls,
    String? location,
    String? condition,
    int? rentalPricePerDay,
    int? discountedPricePerDay,
    DateTime? uploadDate,
    String? description,
    String? brand,
    String? style,
    String? season,
    String? fabricType,
    String? dressType,
    String? color,
    List<String>? sizes,
    String? length,
    String? neckline,
    String? sleeveType,
    List<String>? occasions,
    String? rentalDuration,
    String? fitType,
    bool? isInWatchlist,
  }) {
    return DressListing(
      id: id ?? this.id,
      userIdFk: userIdFk ?? this.userIdFk,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      previewImgUrl: previewImgUrl ?? this.previewImgUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      discountedPricePerDay: discountedPricePerDay ?? this.discountedPricePerDay,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      style: style ?? this.style,
      season: season ?? this.season,
      fabricType: fabricType ?? this.fabricType,
      dressType: dressType ?? this.dressType,
      color: color ?? this.color,
      sizes: sizes ?? this.sizes,
      length: length ?? this.length,
      neckline: neckline ?? this.neckline,
      sleeveType: sleeveType ?? this.sleeveType,
      occasions: occasions ?? this.occasions,
      rentalDuration: rentalDuration ?? this.rentalDuration,
      fitType: fitType ?? this.fitType,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
    );
  }

  @override
  String toString() {
    return 'DressListing(id: $id, ownerUserId: $userIdFk, brand: $brand, style: $style, rentalPricePerDay: $rentalPricePerDay, discountedPricePerDay: $discountedPricePerDay)';
  }
}
