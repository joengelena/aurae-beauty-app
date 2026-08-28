import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/utils/booking_status.dart';

class BookingWithDress {
  final RentalBooking booking;
  final BusinessDress dress;

  const BookingWithDress({required this.booking, required this.dress});
}

class DressRevenue {
  final BusinessDress dress;
  final double revenue;
  final int rentalCount;

  const DressRevenue({
    required this.dress,
    required this.revenue,
    required this.rentalCount,
  });
}

// Bookings in these statuses represent committed/realized income. Pending
// bookings aren't confirmed yet and cancelled ones never happened, so both
// are excluded from revenue.
// Revenue is BookingStatus.countsAsRevenue's call now — expressed as "agreed
// to and not since called off" rather than a list of the statuses that existed
// when this was written.

class WeekScheduleProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  List<BusinessDress> _dresses = [];
  List<RentalBooking> _bookings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Start of upcoming Mon-Sun block (this Monday if today is Mon, else next Mon)
  DateTime get weekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysUntilMonday = (DateTime.monday - today.weekday + 7) % 7;
    return today.add(Duration(days: daysUntilMonday));
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  List<DateTime> get weekDays =>
      List.generate(7, (i) => weekStart.add(Duration(days: i)));

  double get totalRevenue => _bookings
      .where((b) => BookingStatus.countsAsRevenue(b.status))
      .fold(0.0, (sum, b) => sum + b.totalCost);

  List<DressRevenue> topDressesByRevenue({int limit = 5}) {
    final revenueByDressId = <int, double>{};
    for (final b in _bookings) {
      if (!BookingStatus.countsAsRevenue(b.status)) continue;
      revenueByDressId.update(
        b.dressIdFk,
        (v) => v + b.totalCost,
        ifAbsent: () => b.totalCost,
      );
    }

    final ranked = revenueByDressId.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.take(limit).map((e) {
      final dress = _dresses.firstWhere(
        (d) => d.id == e.key,
        orElse: () => _placeholderDress(e.key),
      );
      return DressRevenue(
        dress: dress,
        revenue: e.value,
        rentalCount: dress.rentalCount ?? 0,
      );
    }).toList();
  }

  List<BookingWithDress> bookingsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _bookings
        .where((b) {
          // The schedule shows what is still live. A returned booking is done
          // with the calendar even though it still holds its buffer.
          if (BookingStatus.isClosed(b.status) ||
              b.status == BookingStatus.returned ||
              b.status == BookingStatus.inspected) {
            return false;
          }
          final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
          final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
          return !d.isBefore(start) && !d.isAfter(end);
        })
        .map((b) {
          final dress = _dresses.firstWhere(
            (d) => d.id == b.dressIdFk,
            orElse: () => _placeholderDress(b.dressIdFk),
          );
          return BookingWithDress(booking: b, dress: dress);
        })
        .toList();
  }

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) reset();
    _isSignedIn = isSignedIn;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final dressesFuture = _dressServices.getAllDresses();
      final bookingsFuture = _dressServices.getAllUserBookings();
      _dresses = await dressesFuture;
      _bookings = await bookingsFuture;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load schedule.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _dresses = [];
    _bookings = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  BusinessDress _placeholderDress(int id) => BusinessDress(
        id: id,
        userIdFk: '',
        brand: 'Dress',
        style: '',
        size: '',
        condition: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
