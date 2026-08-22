import 'package:flutter/material.dart';
import 'package:shine_app/data/models/cart_item.dart';
import 'package:shine_app/data/services/cart_services.dart';
import 'package:shine_app/data/services/dress_services.dart';

class CheckoutResult {
  final List<int> bookingIds;
  final List<String> failedItemNames;

  const CheckoutResult({required this.bookingIds, required this.failedItemNames});

  bool get isFullSuccess => failedItemNames.isEmpty;
  bool get isPartialFailure => bookingIds.isNotEmpty && failedItemNames.isNotEmpty;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> items = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isSignedIn = false;

  int get itemCount => items.length;

  List<CartItem> get availableItems =>
      items.where((item) => item.isAvailable).toList();

  bool get hasUnavailableItems => items.any((item) => !item.isAvailable);

  /// Only bookable lines count towards the total — an unavailable dress isn't
  /// something the renter is about to pay for.
  int get total =>
      availableItems.fold<int>(0, (sum, item) => sum + item.totalPrice);

  void updateAuthStatus(bool isSignedIn) {
    if (isSignedIn && !_isSignedIn) {
      fetchCart();
    } else if (!isSignedIn && _isSignedIn) {
      clearCart();
    }
    _isSignedIn = isSignedIn;
  }

  Future<void> fetchCart() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await CartServices().getCart();

      items.clear();
      items.addAll(result);
    } catch (e) {
      errorMessage = 'Failed to load cart';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required int dressId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await CartServices().addToCart(
        dressId: dressId,
        startDate: startDate,
        endDate: endDate,
      );

      // Refetch cart to update local state
      await fetchCart();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await CartServices().removeFromCart(cartItemId);

      items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // No payment step yet — checkout just turns each cart item into a real
  // pending booking (via the same self-book endpoint the dress detail page
  // uses), awaiting the boutique's approval, so the rest of the booking flow
  // can be tested end-to-end.
  Future<CheckoutResult> checkout() async {
    final bookingIds = <int>[];
    final failedItemNames = <String>[];

    for (final item in List<CartItem>.from(items)) {
      // Skipped rather than attempted: the cart already shows these as
      // unavailable, so firing a request we know will 409 would only turn a
      // clear state into a failure message.
      if (!item.isAvailable) {
        failedItemNames.add(item.name ?? item.style);
        continue;
      }

      try {
        final result = await DressServices().selfBook(
          dressId: item.dressIdFk,
          startDate: item.startDate,
          endDate: item.endDate,
        );
        bookingIds.add(result['bookingId'] as int);
        await CartServices().removeFromCart(item.id);
        items.removeWhere((i) => i.id == item.id);
      } catch (e) {
        failedItemNames.add(item.name ?? item.style);
      }
    }

    notifyListeners();
    return CheckoutResult(bookingIds: bookingIds, failedItemNames: failedItemNames);
  }

  void clearCart() {
    items.clear();
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
