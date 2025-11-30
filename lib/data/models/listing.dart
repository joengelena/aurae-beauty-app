import 'dart:convert';

class Listing {
  final int id;
  final String userIdFk;
  final String status;
  final int viewCount;
  final String previewImgUrl;
  final List<dynamic> imageUrls;
  final String location;
  final String vehicleCondition;
  final int originalPrice;
  final int? discountedPrice;
  final DateTime uploadDate;
  final String description;
  final DateTime endDate;
  final String make;
  final String model;
  final int year;
  final int kilometers;
  final String fuelType;
  final String bodyType;
  final String driveType;
  final int? orcIncluded;
  final String? numberPlate;
  final int? seats;
  final int? doors;
  final int? previousOwners;
  final String? color;
  final int? engineSize;
  final String? transmission;
  final int? cylinders;
  final DateTime? regoExpiryDate;
  final DateTime? wofExpiryDate;
  final bool? isInWatchlist;

  Listing({
    required this.id,
    required this.userIdFk,
    required this.status,
    required this.viewCount,
    required this.previewImgUrl,
    required this.imageUrls,
    required this.location,
    required this.vehicleCondition,
    required this.originalPrice,
    this.discountedPrice,
    required this.uploadDate,
    required this.description,
    required this.endDate,
    required this.make,
    required this.model,
    required this.year,
    required this.kilometers,
    required this.fuelType,
    required this.bodyType,
    required this.driveType,
    this.orcIncluded,
    this.numberPlate,
    this.seats,
    this.doors,
    this.previousOwners,
    this.color,
    this.engineSize,
    this.transmission,
    this.cylinders,
    this.regoExpiryDate,
    this.wofExpiryDate,
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
      vehicleCondition: json['vehicleCondition'] as String,
      originalPrice: json['originalPrice'] as int,
      discountedPrice: json['discountedPrice'] as int?,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      description: json['description'] as String,
      endDate: DateTime.parse(json['endDate'] as String),
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      kilometers: json['kilometers'] as int,
      fuelType: json['fuelType'] as String,
      bodyType: json['bodyType'] as String,
      driveType: json['driveType'] as String,
      orcIncluded: json['orcIncluded'] as int?,
      numberPlate: json['numberPlate'] as String?,
      seats: json['seats'] as int?,
      doors: json['doors'] as int?,
      previousOwners: json['previousOwners'] as int?,
      color: json['color'] as String?,
      engineSize: json['engineSize'] as int?,
      transmission: json['transmission'] as String?,
      cylinders: json['cylinders'] as int?,
      regoExpiryDate: json['regoExpiryDate'] as DateTime?,
      wofExpiryDate: json['wofExpiryDate'] as DateTime?,
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
    String? vehicleCondition,
    int? originalPrice,
    int? discountedPrice,
    DateTime? uploadDate,
    String? description,
    DateTime? endDate,
    String? make,
    String? model,
    int? year,
    int? kilometers,
    String? fuelType,
    String? bodyType,
    String? driveType,
    int? orcIncluded,
    String? numberPlate,
    int? seats,
    int? doors,
    int? previousOwners,
    String? color,
    int? engineSize,
    String? transmission,
    int? cylinders,
    DateTime? regoExpiryDate,
    DateTime? wofExpiryDate,
  }) {
    return Listing(
      id: id ?? this.id,
      userIdFk: userIdFk ?? this.userIdFk,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      previewImgUrl: previewImgUrl ?? this.previewImgUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      vehicleCondition: vehicleCondition ?? this.vehicleCondition,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      endDate: endDate ?? this.endDate,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      kilometers: kilometers ?? this.kilometers,
      fuelType: fuelType ?? this.fuelType,
      bodyType: bodyType ?? this.bodyType,
      driveType: driveType ?? this.driveType,
      orcIncluded: orcIncluded ?? this.orcIncluded,
      numberPlate: numberPlate ?? this.numberPlate,
      seats: seats ?? this.seats,
      doors: doors ?? this.doors,
      previousOwners: previousOwners ?? this.previousOwners,
      color: color ?? this.color,
      engineSize: engineSize ?? this.engineSize,
      transmission: transmission ?? this.transmission,
      cylinders: cylinders ?? this.cylinders,
      regoExpiryDate: regoExpiryDate ?? this.regoExpiryDate,
      wofExpiryDate: wofExpiryDate ?? this.wofExpiryDate,
    );
  }

  @override
  String toString() {
    return 'Listing(id: $id, ownerUserId: $userIdFk, make: $make, model: $model, year: $year, originalPrice: $originalPrice, discountedPrice: $discountedPrice)';
  }
}
