import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';

class DressDetailProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  BusinessDress? _dress;
  List<RentalBooking> _bookings = [];
  bool _isLoading = false;
  bool _isLoadingBookings = false;
  String? _errorMessage;
  bool _isSignedIn = false;

  BusinessDress? get dress => _dress;
  List<RentalBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> loadDress(int dressId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dress = await _dressServices.getDressById(dressId);
      await _loadBookingsSilently(dressId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load dress details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBookings(int dressId) async {
    _isLoadingBookings = true;
    notifyListeners();
    await _loadBookingsSilently(dressId);
    _isLoadingBookings = false;
    notifyListeners();
  }

  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    try {
      await _dressServices.addBooking(bookingData);
      final dressId = bookingData['dressIdFk'] as int;
      await _loadBookingsSilently(dressId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to add booking: ${e.toString()}');
    }
  }

  Future<void> deleteBooking(int bookingId, int dressId) async {
    try {
      await _dressServices.deleteBooking(bookingId, dressId);
      _bookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete booking: ${e.toString()}');
    }
  }

  Future<void> _loadBookingsSilently(int dressId) async {
    try {
      _bookings = await _dressServices.getBookingsByDressId(dressId);
    } catch (_) {
      // Non-critical — show empty state
    }
  }

  void reset() {
    _dress = null;
    _bookings = [];
    _isLoading = false;
    _isLoadingBookings = false;
    _errorMessage = null;
    notifyListeners();
  }
}
