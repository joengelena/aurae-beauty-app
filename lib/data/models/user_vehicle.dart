class UserVehicle {
  final int id;
  final String userIdFk;
  final String make;
  final String model;
  final int year;
  final String? licensePlate;
  final String? color;
  final String? fuelType;
  final String? transmission;
  final int? odometerReading;
  final String odometerUnit;
  final String? regoExpiryDate;
  final String? wofExpiryDate;
  final String? vehiclePhotoUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserVehicle({
    required this.id,
    required this.userIdFk,
    required this.make,
    required this.model,
    required this.year,
    this.licensePlate,
    this.color,
    this.fuelType,
    this.transmission,
    this.odometerReading,
    required this.odometerUnit,
    this.regoExpiryDate,
    this.wofExpiryDate,
    this.vehiclePhotoUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserVehicle.fromJson(Map<String, dynamic> json) {
    return UserVehicle(
      id: json['id'] as int,
      userIdFk: json['userIdFk'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['licensePlate'] as String?,
      color: json['color'] as String?,
      fuelType: json['fuelType'] as String?,
      transmission: json['transmission'] as String?,
      odometerReading: json['odometerReading'] as int?,
      odometerUnit: json['odometerUnit'] as String? ?? 'km',
      regoExpiryDate: json['regoExpiryDate'] as String?,
      wofExpiryDate: json['wofExpiryDate'] as String?,
      vehiclePhotoUrl: json['vehiclePhotoUrl'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIdFk': userIdFk,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'fuelType': fuelType,
      'transmission': transmission,
      'odometerReading': odometerReading,
      'odometerUnit': odometerUnit,
      'regoExpiryDate': regoExpiryDate,
      'wofExpiryDate': wofExpiryDate,
      'vehiclePhotoUrl': vehiclePhotoUrl,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
