import 'dart:convert';

class Listing {
  final int id;
  final String userIdFk;
  final int viewCount;
  final String previewImgUrl;
  final List<dynamic> imageUrls;
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
  final DateTime? regoExpiryDate;
  final DateTime? wofExpiryDate;

  Listing({
    required this.id,
    required this.userIdFk,
    required this.viewCount,
    required this.previewImgUrl,
    required this.imageUrls,
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

  factory Listing.fromJson(json) {
    return Listing(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      viewCount: json['viewCount'] as int,
      previewImgUrl: json['previewImgUrl'] as String,
      imageUrls: json['imageUrls'] as List<dynamic>,
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
      regoExpiryDate: json['regoExpiryDate'] as DateTime?,
      wofExpiryDate: json['wofExpiryDate'] as DateTime?,
    );
  }

  factory Listing.fromJsonString(String jsonString) =>
      Listing.fromJson(json.decode(jsonString));

  @override
  String toString() {
    return 'Listing(id: $id, ownerUserId: $userIdFk, make: $make, model: $model, year: $year, price: $price)';
  }
}
