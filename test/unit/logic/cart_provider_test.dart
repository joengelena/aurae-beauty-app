import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/cart_item.dart';
import 'package:shine_app/logic/cart_provider.dart';

// Only the parts of CartProvider that never reach CartServices/DressServices
// are exercised here: derived getters, clearCart, and a checkout in which
// every line is already unavailable (skipped before any request is made).

CartItem _item({
  required int id,
  required DateTime start,
  required DateTime end,
  int pricePerDay = 100,
  bool isAvailable = true,
  String? name,
  String style = 'Wrap',
}) =>
    CartItem(
      id: id,
      dressIdFk: 40 + id,
      startDate: start,
      endDate: end,
      pricePerDay: pricePerDay,
      createdAt: DateTime.utc(2026, 9, 20),
      name: name,
      brand: 'Zimmermann',
      style: style,
      size: '8',
      dressPhotoUrl: '',
      location: 'Christchurch City',
      isAvailable: isAvailable,
    );

void main() {
  group('CartProvider derived state', () {
    test('an empty cart has nothing to pay', () {
      final cart = CartProvider();
      expect(cart.itemCount, 0);
      expect(cart.total, 0);
      expect(cart.hasUnavailableItems, isFalse);
      expect(cart.availableItems, isEmpty);
    });

    test('total is nights times nightly price, summed over the lines', () {
      final cart = CartProvider();
      cart.items.addAll([
        // 2 nights at $100
        _item(id: 1, start: DateTime(2026, 10, 9), end: DateTime(2026, 10, 11)),
        // 1 night at $85
        _item(
            id: 2,
            start: DateTime(2026, 10, 23),
            end: DateTime(2026, 10, 24),
            pricePerDay: 85),
      ]);
      expect(cart.itemCount, 2);
      expect(cart.total, 285);
    });

    test('a line across NZ spring-forward is not a night short', () {
      final cart = CartProvider();
      cart.items.add(
          _item(id: 1, start: DateTime(2026, 9, 26), end: DateTime(2026, 9, 28)));
      expect(cart.total, 200);
    });

    test('unavailable lines are flagged and left out of the total', () {
      final cart = CartProvider();
      cart.items.addAll([
        _item(id: 1, start: DateTime(2026, 10, 9), end: DateTime(2026, 10, 11)),
        _item(
            id: 2,
            start: DateTime(2026, 10, 9),
            end: DateTime(2026, 10, 12),
            isAvailable: false),
      ]);
      expect(cart.hasUnavailableItems, isTrue);
      expect(cart.availableItems.map((i) => i.id).toList(), [1]);
      expect(cart.total, 200);
    });

    test('clearCart empties the cart and tells listeners', () {
      final cart = CartProvider();
      cart.items.add(
          _item(id: 1, start: DateTime(2026, 10, 9), end: DateTime(2026, 10, 11)));
      var notified = 0;
      cart.addListener(() => notified++);
      cart.clearCart();
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
      expect(cart.errorMessage, isNull);
      expect(cart.isLoading, isFalse);
      expect(notified, greaterThan(0));
    });
  });

  group('CartProvider.checkout with only unavailable lines', () {
    test('books nothing and reports every line as failed by name', () async {
      final cart = CartProvider();
      cart.items.addAll([
        _item(
            id: 1,
            start: DateTime(2026, 10, 9),
            end: DateTime(2026, 10, 11),
            isAvailable: false,
            name: 'Rosa Wrap Midi'),
        _item(
            id: 2,
            start: DateTime(2026, 10, 9),
            end: DateTime(2026, 10, 11),
            isAvailable: false,
            style: 'Halter'),
      ]);

      final result = await cart.checkout();

      expect(result.bookingIds, isEmpty);
      // A dress with no public name is named by its style.
      expect(result.failedItemNames, ['Rosa Wrap Midi', 'Halter']);
      expect(result.isFullSuccess, isFalse);
      expect(result.isPartialFailure, isFalse);
      // Still in the cart, so the renter can see what happened to them.
      expect(cart.itemCount, 2);
    });
  });

  group('CheckoutResult', () {
    test('everything booked is a full success', () {
      const r = CheckoutResult(bookingIds: [1, 2], failedItemNames: []);
      expect(r.isFullSuccess, isTrue);
      expect(r.isPartialFailure, isFalse);
    });

    test('some booked and some not is a partial failure', () {
      const r = CheckoutResult(bookingIds: [1], failedItemNames: ['Halter']);
      expect(r.isFullSuccess, isFalse);
      expect(r.isPartialFailure, isTrue);
    });

    test('nothing booked is a failure, not a partial one', () {
      const r = CheckoutResult(bookingIds: [], failedItemNames: ['Halter']);
      expect(r.isFullSuccess, isFalse);
      expect(r.isPartialFailure, isFalse);
    });
  });
}
