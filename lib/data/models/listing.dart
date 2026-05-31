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
  final String brand;
  final String style;
  final String size;
  final String? color;
  final String? dressType;
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
    required this.brand,
    required this.style,
    required this.size,
    this.color,
    this.dressType,
    this.isInWatchlist,
  });

  factory Listing.fromJson(json) {
    return Listing(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      status: json['status'] as String,
      viewCount: json['viewCount'] as int,
      previewImgUrl: json['previewImgUrl'] as String,
      imageUrls: json['imageUrls'] as List<dynamic>,
      location: json['location'] as String,
      condition: json['condition'] as String,
      pricePerDay: json['pricePerDay'] as int,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      description: json['description'] as String,
      brand: json['brand'] as String,
      style: json['style'] as String,
      size: json['size'] as String,
      color: json['color'] as String?,
      dressType: json['dressType'] as String?,
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
    String? brand,
    String? style,
    String? size,
    String? color,
    String? dressType,
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
      brand: brand ?? this.brand,
      style: style ?? this.style,
      size: size ?? this.size,
      color: color ?? this.color,
      dressType: dressType ?? this.dressType,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
    );
  }

  @override
  String toString() {
    return 'Listing(id: $id, userIdFk: $userIdFk, brand: $brand, style: $style, size: $size, pricePerDay: $pricePerDay)';
  }
}
