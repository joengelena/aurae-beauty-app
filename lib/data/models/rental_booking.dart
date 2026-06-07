class RentalBooking {
  final int id;
  final int dressIdFk;
  final String bookingType;
  final DateTime bookingDate;
  final String? renterName;
  final String? renterEmail;
  final String? renterPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final double? depositPaid;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalBooking({
    required this.id,
    required this.dressIdFk,
    required this.bookingType,
    required this.bookingDate,
    this.renterName,
    this.renterEmail,
    this.renterPhone,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    this.depositPaid,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalBooking.fromJson(Map<String, dynamic> json) {
    return RentalBooking(
      id: json['id'] as int,
      dressIdFk: json['dressIdFk'] as int,
      bookingType: json['bookingType'] as String? ?? 'rental',
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      renterName: json['renterName'] as String?,
      renterEmail: json['renterEmail'] as String?,
      renterPhone: json['renterPhone'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalCost: json['totalCost'] != null ? (json['totalCost'] as num).toDouble() : 0.0,
      depositPaid: json['depositPaid'] != null ? (json['depositPaid'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dressIdFk': dressIdFk,
      'bookingType': bookingType,
      'bookingDate': bookingDate.toIso8601String(),
      'renterName': renterName,
      'renterEmail': renterEmail,
      'renterPhone': renterPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCost': totalCost,
      'depositPaid': depositPaid,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
