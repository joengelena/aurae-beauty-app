import 'package:motorix_app/data/models/preview_listing.dart';
import 'package:motorix_app/data/models/public_profile.dart';

class DetailedListing extends PreviewListing {
  final List<String> images;
  final PublicProfile sellerInfo;

  DetailedListing({
    required this.images,
    required this.sellerInfo,
    required super.id,
    required super.userIdFk,
    required super.viewCount,
    required super.previewImgUrl,
    required super.location,
    required super.vehicleCondition,
    required super.price,
    required super.uploadDate,
    required super.description,
    required super.endDate,
    required super.make,
    required super.model,
    required super.year,
    required super.kilometers,
    required super.fuelType,
    required super.bodyType,
    required super.driveType,
    super.orcIncluded,
    super.numberPlate,
    super.seats,
    super.doors,
    super.previousOwners,
    super.color,
    super.engineSize,
    super.transmission,
    super.cylinders,
    super.regoExpiryDate,
    super.wofExpiryDate,
  });

  factory DetailedListing.fromJson(Map<String, dynamic> json) {
    return DetailedListing(
      images: List<String>.from(json['images']),
      sellerInfo: PublicProfile.fromJson(json['sellerInfo']),
      id: json['id'],
      userIdFk: json['userIdFk'],
      viewCount: json['viewCount'],
      previewImgUrl: json['previewImgUrl'],
      location: json['location'],
      vehicleCondition: json['vehicleCondition'],
      price: json['price'],
      uploadDate: DateTime.parse(json['uploadDate']),
      description: json['description'],
      endDate: DateTime.parse(json['endDate']),
      make: json['make'],
      model: json['model'],
      year: json['year'],
      kilometers: json['kilometers'],
      fuelType: json['fuelType'],
      bodyType: json['bodyType'],
      driveType: json['driveType'],
      orcIncluded: json['orcIncluded'],
      numberPlate: json['numberPlate'],
      seats: json['seats'],
      doors: json['doors'],
      previousOwners: json['previousOwners'],
      color: json['color'],
      engineSize: json['engineSize'],
      transmission: json['transmission'],
      cylinders: json['cylinders'],
      regoExpiryDate: json['regoExpiryDate'],
      wofExpiryDate: json['wofExpiryDate'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['images'] = images;
    json['sellerInfo'] = sellerInfo;
    return json;
  }

  @override
  String toString() {
    return '${super.toString()}, images: ${images.length}, seller: $sellerInfo';
  }
}
