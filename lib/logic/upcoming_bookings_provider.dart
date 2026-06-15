import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';

class UpcomingBookingsProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  List<UpcomingBooking> _bookings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  DateTime get weekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysUntilMonday = (DateTime.monday - today.weekday + 7) % 7;
    return today.add(Duration(days: daysUntilMonday));
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  List<DateTime> get weekDays =>
      List.generate(7, (i) => weekStart.add(Duration(days: i)));

  List<UpcomingBooking> bookingsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _bookings.where((b) {
      final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
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
      _bookings = await _dressServices.getMyBookings();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _bookings = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
