import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business.dart';
import 'package:shine_app/data/services/business_services.dart';
import 'package:shine_app/utils/secure_storage.dart';

/// Tracks which context the signed-in account is currently acting as: the
/// implicit Customer profile (always available), or their business (Owner
/// or Staff — at most one, enforced server-side). Which one is "active" is
/// a client-side UI preference only, persisted locally — it decides what
/// the app shows, never something the server needs to trust.
class ActiveProfileProvider extends ChangeNotifier {
  final BusinessServices _businessServices = BusinessServices();

  static const _activeProfileKey = 'activeProfileIsBusiness';

  Business? _business;
  String? _role;
  bool _isBusinessActive = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignedIn = false;

  bool get hasBusiness => _business != null;
  Business? get business => _business;
  String? get role => _role;
  bool get isBusinessActive => _isBusinessActive;

  /// Whether renter-side actions — booking, cart, My Bookings — are available
  /// right now. Every gate in the app reads this rather than negating
  /// [isBusinessActive] in a dozen places.
  ///
  /// This is a **mode, not a permission.** Any account can switch to its
  /// Customer profile in one tap and book legitimately, including an owner
  /// booking their own dresses. So this is never enforced server-side; it
  /// scopes what the app shows so the two contexts don't bleed into each
  /// other. Don't reach for it as a security boundary — it isn't one.
  bool get canActAsRenter => !_isBusinessActive;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  void updateAuthStatus(bool isSignedIn) {
    if (!isSignedIn && _isSignedIn) {
      reset();
    } else if (isSignedIn && !_isSignedIn) {
      loadMyBusiness();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> loadMyBusiness() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _businessServices.getMyBusiness();
      _business = result.business;
      _role = result.role;

      if (!hasBusiness) {
        _isBusinessActive = false;
      } else {
        final stored = await SecureStorage.read(_activeProfileKey);
        _isBusinessActive = stored != null ? stored == 'true' : true;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading your business.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBusiness(String name) async {
    try {
      final business = await _businessServices.createBusiness(name);
      _business = business;
      _role = 'owner';
      await setActiveProfile(true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create business: ${e.toString()}');
    }
  }

  Future<void> redeemInviteCode(String code) async {
    try {
      final result = await _businessServices.redeemInviteCode(code);
      _business = result.business;
      _role = result.role;
      await setActiveProfile(true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to redeem invite code: ${e.toString()}');
    }
  }

  Future<String> generateInviteCode(String role) async {
    if (!hasBusiness) {
      throw AppException('You need a business to invite team members.');
    }

    try {
      return await _businessServices.generateInviteCode(_business!.id, role);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create invite: ${e.toString()}');
    }
  }

  Future<void> setActiveProfile(bool isBusiness) async {
    if (isBusiness && !hasBusiness) return;

    _isBusinessActive = isBusiness;
    await SecureStorage.write(_activeProfileKey, isBusiness.toString());
    notifyListeners();
  }

  void reset() {
    _business = null;
    _role = null;
    _isBusinessActive = false;
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
