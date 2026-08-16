import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';

const _openStatuses = ['pending', 'confirmed'];
const _closedStatuses = ['returned', 'cancelled'];
const _previewWindowDays = 30;

bool isBookingCancellable(UpcomingBooking booking) =>
    _openStatuses.contains(booking.status);

class MyBookingsProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  List<UpcomingBooking> _bookings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  /// Not yet returned or cancelled — soonest first.
  List<UpcomingBooking> get upcoming {
    final list = _bookings
        .where((b) => !_closedStatuses.contains(b.status))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return List.unmodifiable(list);
  }

  /// Returned or cancelled — most recent first.
  List<UpcomingBooking> get past {
    final list = _bookings
        .where((b) => _closedStatuses.contains(b.status))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return List.unmodifiable(list);
  }

  /// Upcoming bookings (any status, including pending review) starting
  /// within the next 30 days — used for the Profile preview card.
  List<UpcomingBooking> get upcomingWithinMonth {
    final cutoff = DateTime.now().add(const Duration(days: _previewWindowDays));
    return List.unmodifiable(upcoming.where((b) => !b.startDate.isAfter(cutoff)));
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
      _errorMessage = 'Failed to load your bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancel(int bookingId) async {
    try {
      await _dressServices.cancelMyBooking(bookingId);
      await load();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to cancel booking: ${e.toString()}');
    }
  }

  void reset() {
    _bookings = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
