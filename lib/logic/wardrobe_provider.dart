import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/services/dress_services.dart';

class WardrobeProvider extends ChangeNotifier {
  final DressServices _dressServices = DressServices();

  List<BusinessDress> _dresses = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  List<BusinessDress> get dresses => _dresses;
  List<BusinessDress> get activeDresses =>
      _dresses.where((d) => d.status != 'sold').toList();
  List<BusinessDress> get soldDresses =>
      _dresses.where((d) => d.status == 'sold').toList();

  /// How many dresses the Wardrobe overview shows before "View all".
  static const int overviewDressCount = 5;

  /// A dress the owner has something to do about: a booking request waiting on
  /// her, or damage she hasn't closed off.
  static bool _needsAttention(BusinessDress d) =>
      d.pendingBookingCount > 0 || d.unresolvedDamageCount > 0;

  /// Active dresses with the ones needing attention first.
  ///
  /// Partitioned rather than sorted: Dart's sort isn't stable, and the API
  /// already returns newest-first, so splitting the list preserves recency
  /// inside each group without a second sort key.
  List<BusinessDress> get dressesByAttention {
    final active = activeDresses;
    return [
      ...active.where(_needsAttention),
      ...active.where((d) => !_needsAttention(d)),
    ];
  }

  /// The slice shown on the overview rail.
  List<BusinessDress> get overviewDresses =>
      dressesByAttention.take(overviewDressCount).toList();

  /// True once there is more inventory than the rail can show, which is the
  /// only time "View all" has anything extra behind it.
  bool get hasMoreThanOverview =>
      activeDresses.length > overviewDressCount || soldDresses.isNotEmpty;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> fetchDresses() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _dresses = await _dressServices.getAllDresses();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading your dresses.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDress(
    Map<String, dynamic> dressData, {
    List<Uint8List> photoBytes = const [],
    List<String?> photoMimeTypes = const [],
  }) async {
    try {
      await _dressServices.addDress(
        dressData,
        photoBytes: photoBytes,
        photoMimeTypes: photoMimeTypes,
      );
      await fetchDresses();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to add dress: ${e.toString()}');
    }
  }

  Future<void> updateDress(
    int dressId,
    Map<String, Object> updates, {
    List<Uint8List> newPhotoBytes = const [],
    List<String?> newPhotoMimeTypes = const [],
    List<String> keepPhotoUrls = const [],
    List<DateTimeRange>? blockedDateRanges,
  }) async {
    try {
      await _dressServices.updateDress(
        dressId,
        updates,
        newPhotoBytes: newPhotoBytes,
        newPhotoMimeTypes: newPhotoMimeTypes,
        keepPhotoUrls: keepPhotoUrls,
        blockedDateRanges: blockedDateRanges,
      );
      await fetchDresses();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update dress: ${e.toString()}');
    }
  }

  Future<void> markAsSold(int dressId) async {
    await updateDress(dressId, {'status': 'sold'});
  }

  Future<void> reactivate(int dressId) async {
    await updateDress(dressId, {'status': 'active'});
  }

  Future<void> deleteDress(int dressId) async {
    try {
      await _dressServices.deleteDress(dressId);
      _dresses.removeWhere((d) => d.id == dressId);
      notifyListeners();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete dress: ${e.toString()}');
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void reset() {
    _dresses = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
