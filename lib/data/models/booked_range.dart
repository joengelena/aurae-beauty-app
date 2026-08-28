import 'package:shine_app/utils/booking_status.dart';

class BookedRange {
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const BookedRange({
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory BookedRange.fromJson(Map<String, dynamic> json) {
    return BookedRange(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String? ?? BookingStatus.approved,
    );
  }

  /// Anything the availability endpoint sends is blocking unless the booking
  /// was called off. Delegated to BookingStatus so this can't drift from the
  /// rest of the app — or from booking_holds_dates() in the database.
  ///
  /// Note 'blocked', which manual blackout ranges carry: it isn't a booking
  /// status at all, and falls through to holding its dates, which is right.
  bool get isUnavailable => BookingStatus.holdsDates(status);
}
