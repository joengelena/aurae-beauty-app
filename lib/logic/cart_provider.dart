import 'package:flutter/material.dart';
import 'package:shine_app/data/models/cart_item.dart';
import 'package:shine_app/data/services/cart_services.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> items = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isSignedIn = false;

  int get itemCount => items.length;

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

  void clearCart() {
    items.clear();
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
