import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/dress_damage_incident.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/data/services/dress_services.dart';

class DressDetailProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  BusinessDress? _dress;
  List<RentalBooking> _bookings = [];
  List<DressDamageIncident> _damageIncidents = [];
  bool _isLoading = false;
  bool _isLoadingBookings = false;
  bool _isLoadingDamageIncidents = false;
  String? _errorMessage;
  bool _isSignedIn = false;

  BusinessDress? get dress => _dress;
  List<RentalBooking> get bookings => _bookings;
  List<DressDamageIncident> get damageIncidents => _damageIncidents;
  bool get isLoading => _isLoading;
  bool get isLoadingBookings => _isLoadingBookings;
  bool get isLoadingDamageIncidents => _isLoadingDamageIncidents;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> loadDress(int dressId) async {
    // Start from a clean slate so a different dress never shows the previous
    // one's bookings or damage while (or if) its own fail to load.
    if (_dress?.id != dressId) _dress = null;
    _bookings = [];
    _damageIncidents = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dress = await _dressServices.getDressById(dressId);
      await _loadBookingsSilently(dressId);
      await _loadDamageIncidentsSilently(dressId);
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
      throw AppException(
        userMessage(e, fallback: "Could not save that booking. Please try again."),
      );
    }
  }

  Future<void> updateBookingStatus(
    int bookingId,
    int dressId,
    String status,
  ) async {
    try {
      await _dressServices.updateBooking(bookingId, dressId, {'status': status});
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
        notifyListeners();
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        userMessage(e, fallback: "Could not update that booking. Please try again."),
      );
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
      throw AppException(
        userMessage(e, fallback: "Could not delete that booking. Please try again."),
      );
    }
  }

  Future<void> refreshDamageIncidents(int dressId) async {
    _isLoadingDamageIncidents = true;
    notifyListeners();
    await _loadDamageIncidentsSilently(dressId);
    _isLoadingDamageIncidents = false;
    notifyListeners();
  }

  Future<void> addDamageIncident(
    int dressId,
    Map<String, dynamic> incidentData, {
    List<Uint8List> photoBytes = const [],
    List<String?> photoMimeTypes = const [],
  }) async {
    try {
      await _dressServices.addDamageIncident(
        dressId,
        incidentData,
        photoBytes: photoBytes,
        photoMimeTypes: photoMimeTypes,
      );
      await _loadDamageIncidentsSilently(dressId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        userMessage(e, fallback: "Could not save that damage report. Please try again."),
      );
    }
  }

  Future<void> updateDamageIncident(
    int dressId,
    int incidentId,
    Map<String, dynamic> updates, {
    List<Uint8List> newPhotoBytes = const [],
    List<String?> newPhotoMimeTypes = const [],
    List<String>? keepPhotoUrls,
  }) async {
    try {
      await _dressServices.updateDamageIncident(
        dressId,
        incidentId,
        updates,
        newPhotoBytes: newPhotoBytes,
        newPhotoMimeTypes: newPhotoMimeTypes,
        keepPhotoUrls: keepPhotoUrls,
      );
      await _loadDamageIncidentsSilently(dressId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        userMessage(e, fallback: "Could not update that damage report. Please try again."),
      );
    }
  }

  Future<void> deleteDamageIncident(int dressId, int incidentId) async {
    try {
      await _dressServices.deleteDamageIncident(dressId, incidentId);
      _damageIncidents.removeWhere((i) => i.id == incidentId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        userMessage(e, fallback: "Could not delete that damage report. Please try again."),
      );
    }
  }

  Future<void> _loadBookingsSilently(int dressId) async {
    try {
      _bookings = await _dressServices.getBookingsByDressId(dressId);
    } catch (_) {
      // Non-critical — show empty state rather than another dress's bookings
      _bookings = [];
    }
  }

  Future<void> _loadDamageIncidentsSilently(int dressId) async {
    try {
      _damageIncidents = await _dressServices.getDamageIncidents(dressId);
    } catch (_) {
      // Non-critical — show empty state rather than another dress's incidents
      _damageIncidents = [];
    }
  }

  void reset() {
    _dress = null;
    _bookings = [];
    _damageIncidents = [];
    _isLoading = false;
    _isLoadingBookings = false;
    _isLoadingDamageIncidents = false;
    _errorMessage = null;
    notifyListeners();
  }
}
