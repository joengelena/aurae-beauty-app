import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';

class BookingWithDress {
  final RentalBooking booking;
  final BusinessDress dress;

  const BookingWithDress({required this.booking, required this.dress});
}

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

  List<BookingWithDress> bookingsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _bookings
        .where((b) {
          if (b.status == 'cancelled' || b.status == 'returned') return false;
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
