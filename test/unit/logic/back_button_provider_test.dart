import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/logic/back_button_provider.dart';

void main() {
  group('BackButtonProvider', () {
    test('starts with no history', () {
      final p = BackButtonProvider();
      expect(p.hasHistory, isFalse);
      expect(p.routeStack, isEmpty);
      expect(p.popRoute(), isNull);
    });

    test('pops routes last-in, first-out', () {
      final p = BackButtonProvider()
        ..pushRoute('/listings')
        ..pushRoute('/listings/42');
      expect(p.hasHistory, isTrue);
      expect(p.popRoute(), '/listings/42');
      expect(p.popRoute(), '/listings');
      expect(p.hasHistory, isFalse);
      expect(p.popRoute(), isNull);
    });

    test('reset clears the history', () {
      final p = BackButtonProvider()
        ..pushRoute('/wardrobe')
        ..pushRoute('/wardrobe/dress/7');
      p.reset();
      expect(p.hasHistory, isFalse);
      expect(p.routeStack, isEmpty);
    });

    test('notifies listeners on every change', () {
      final p = BackButtonProvider();
      var notified = 0;
      p.addListener(() => notified++);
      p.pushRoute('/a');
      p.popRoute();
      p.reset();
      expect(notified, 3);
    });

    test('the exposed stack cannot be modified from outside', () {
      final p = BackButtonProvider()..pushRoute('/a');
      expect(() => p.routeStack.add('/b'), throwsUnsupportedError);
      expect(p.routeStack, ['/a']);
    });
  });
}
