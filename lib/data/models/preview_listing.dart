import 'dart:convert';

class PreviewListing {
  final int id;
  final String userIdFk;
  final int viewCount;
  final String previewImgUrl;
  final String location;
  final String vehicleCondition;
  final int price;
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
  final String? regoExpiryDate;
  final String? wofExpiryDate;

  PreviewListing({
    required this.id,
    required this.userIdFk,
    required this.viewCount,
    required this.previewImgUrl,
    required this.location,
    required this.vehicleCondition,
    required this.price,
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
  });

  /// Creates a new Listing from a JSON map.
  factory PreviewListing.fromJson(Map<String, dynamic> json) {
    return PreviewListing(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      viewCount: json['viewCount'] as int,
      previewImgUrl: json['previewImgUrl'] as String,
      location: json['location'] as String,
      vehicleCondition: json['vehicleCondition'] as String,
      price: json['price'] as int,
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
      regoExpiryDate: json['regoExpiryDate'] as String?,
      wofExpiryDate: json['wofExpiryDate'] as String?,
    );
  }

  /// Converts this Listing into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIdFk': userIdFk,
      'viewCount': viewCount,
      'previewImgUrl': previewImgUrl,
      'location': location,
      'vehicleCondition': vehicleCondition,
      'price': price,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'endDate': endDate.toIso8601String(),
      'make': make,
      'model': model,
      'year': year,
      'kilometers': kilometers,
      'fuelType': fuelType,
      'bodyType': bodyType,
      'driveType': driveType,
      'orcIncluded': orcIncluded,
      'numberPlate': numberPlate,
      'seats': seats,
      'doors': doors,
      'previousOwners': previousOwners,
      'color': color,
      'engineSize': engineSize,
      'transmission': transmission,
      'cylinders': cylinders,
      'regoExpiryDate': regoExpiryDate,
      'wofExpiryDate': wofExpiryDate,
    };
  }

  /// Convenience to parse directly from a JSON string.
  factory PreviewListing.fromJsonString(String jsonString) =>
      PreviewListing.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  /// Convenience to convert to a JSON string.
  String toJsonString() => json.encode(toJson());

  @override
  String toString() {
    return 'Listing(id: $id, ownerUserId: $userIdFk, make: $make, model: $model, year: $year, price: $price)';
  }
}
