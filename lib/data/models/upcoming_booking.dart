import 'package:shine_app/utils/booking_status.dart';

class UpcomingBooking {
  final int id;
  final int dressIdFk;
  final String bookingType;
  final DateTime bookingDate;
  final DateTime startDate;
  final DateTime endDate;
  final String renterName;
  final String? renterEmail;
  final double totalCost;
  final double? depositPaid;
  final String status;
  final String? notes;
  final String dressBrand;
  final String dressStyle;
  final String? dressPhotoUrl;
  final String? dressInternalName;

  UpcomingBooking({
    required this.id,
    required this.dressIdFk,
    required this.bookingType,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.renterName,
    this.renterEmail,
    required this.totalCost,
    this.depositPaid,
    required this.status,
    this.notes,
    required this.dressBrand,
    required this.dressStyle,
    this.dressPhotoUrl,
    this.dressInternalName,
  });

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    return UpcomingBooking(
      id: json['id'] as int,
      dressIdFk: json['dressIdFk'] as int,
      bookingType: json['bookingType'] as String? ?? 'rental',
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      renterName: json['renterName'] as String? ?? '',
      renterEmail: json['renterEmail'] as String?,
      totalCost: json['totalCost'] != null ? (json['totalCost'] as num).toDouble() : 0.0,
      depositPaid: json['depositPaid'] != null ? (json['depositPaid'] as num).toDouble() : null,
      status: json['status'] as String? ?? BookingStatus.approved,
      notes: json['notes'] as String?,
      dressBrand: json['dressBrand'] as String? ?? '',
      dressStyle: json['dressStyle'] as String? ?? '',
      dressPhotoUrl: json['dressPhotoUrl'] as String?,
      dressInternalName: json['dressInternalName'] as String?,
    );
  }
}
