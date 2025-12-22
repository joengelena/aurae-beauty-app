class VehicleService {
  final int id;
  final int vehicleIdFk;
  final String typeOfService;
  final DateTime serviceDate;
  final String? serviceProviderName;
  final double? cost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleService({
    required this.id,
    required this.vehicleIdFk,
    required this.typeOfService,
    required this.serviceDate,
    this.serviceProviderName,
    this.cost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleService.fromJson(Map<String, dynamic> json) {
    return VehicleService(
      id: json['id'] as int,
      vehicleIdFk: json['vehicleIdFk'] as int,
      typeOfService: json['typeOfService'] as String,
      serviceDate: DateTime.parse(json['serviceDate'] as String),
      serviceProviderName: json['serviceProviderName'] as String?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
