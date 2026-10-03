import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/utils/size_utils.dart';

void main() {
  group('sizeRank', () {
    test('orders letter sizes smallest to largest', () {
      const letters = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];
      for (var i = 0; i < letters.length - 1; i++) {
        expect(sizeRank(letters[i]) < sizeRank(letters[i + 1]), isTrue,
            reason: '${letters[i]} before ${letters[i + 1]}');
      }
    });

    test('orders numeric sizes by value, not alphabetically', () {
      expect(sizeRank('4') < sizeRank('6'), isTrue);
      expect(sizeRank('8') < sizeRank('10'), isTrue);
      expect(sizeRank('10') < sizeRank('16'), isTrue);
    });

    test('puts letter sizes before numeric ones, unknown sizes last', () {
      // Same order as sizeRankCase in shine_api's dressRepository.ts.
      final sizes = ['One size', '12', 'M', '6', 'XXL', 'XS', '10', 'S'];
      sizes.sort((a, b) => sizeRank(a).compareTo(sizeRank(b)));
      expect(sizes, ['XS', 'S', 'M', 'XXL', '6', '10', '12', 'One size']);
    });

    test('an unknown size sorts after a large numeric size', () {
      expect(sizeRank('Free size') > sizeRank('26'), isTrue);
    });
  });
}
