import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/utils/utils.dart';

/// NZ daylight saving: starts on the last Sunday of September (clocks go
/// forward, a 23-hour day) and ends on the first Sunday of April (clocks go
/// back, a 25-hour day). These tests only exercise the transition when the
/// machine is on NZ time — run them with `TZ=Pacific/Auckland flutter test`
/// to be sure. On any other zone they still check calendar arithmetic.
final _dstStart2026 = DateTime(2026, 9, 27);
final _dstEnd2026 = DateTime(2026, 4, 5);
final _dstEnd2027 = DateTime(2027, 4, 4);

void _expectMidnight(DateTime d) {
  expect(d.isUtc, isFalse, reason: 'should be a local date, got $d');
  expect([d.hour, d.minute, d.second, d.millisecond], [0, 0, 0, 0],
      reason: 'should be midnight, got $d');
}

void main() {
  group('addDays', () {
    test('moves forward one calendar day to midnight', () {
      final result = addDays(DateTime(2026, 10, 14), 1);
      expect(result, DateTime(2026, 10, 15));
      _expectMidnight(result);
    });

    test('lands on the day of the spring-forward change, at midnight', () {
      final result = addDays(DateTime(2026, 9, 26), 1);
      expect([result.year, result.month, result.day], [2026, 9, 27]);
      _expectMidnight(result);
    });

    test('lands on the day after the spring-forward change, at midnight', () {
      final result = addDays(_dstStart2026, 1);
      expect([result.year, result.month, result.day], [2026, 9, 28]);
      _expectMidnight(result);
    });

    test('lands on the day of the fall-back change, at midnight', () {
      final result = addDays(DateTime(2026, 4, 4), 1);
      expect([result.year, result.month, result.day], [2026, 4, 5]);
      _expectMidnight(result);
    });

    test('lands on the day after the fall-back change, at midnight', () {
      final result = addDays(_dstEnd2026, 1);
      expect([result.year, result.month, result.day], [2026, 4, 6]);
      _expectMidnight(result);
    });

    test('a week-long rental across spring-forward ends on the right day', () {
      expect(addDays(DateTime(2026, 9, 24), 7), DateTime(2026, 10, 1));
    });

    test('moving backwards across the change works too', () {
      expect(addDays(DateTime(2026, 9, 28), -2), DateTime(2026, 9, 26));
      expect(addDays(DateTime(2026, 4, 6), -2), DateTime(2026, 4, 4));
    });

    test('stepping day by day across spring-forward skips and repeats nothing',
        () {
      final expected = <List<int>>[
        for (var d = 20; d <= 30; d++) [9, d],
        for (var d = 1; d <= 5; d++) [10, d],
      ];
      var current = DateTime(2026, 9, 20);
      final visited = <List<int>>[];
      for (var i = 0; i < expected.length; i++) {
        _expectMidnight(current);
        visited.add([current.month, current.day]);
        current = addDays(current, 1);
      }
      expect(visited, expected);
    });

    test('stepping day by day across fall-back skips and repeats nothing', () {
      final expected = <List<int>>[
        for (var d = 28; d <= 31; d++) [3, d],
        for (var d = 1; d <= 10; d++) [4, d],
      ];
      var current = DateTime(2027, 3, 28);
      final visited = <List<int>>[];
      for (var i = 0; i < expected.length; i++) {
        _expectMidnight(current);
        visited.add([current.month, current.day]);
        current = addDays(current, 1);
      }
      expect(visited, expected);
      expect(visited, anyElement(equals([_dstEnd2027.month, _dstEnd2027.day])));
    });

    test('rolls over month and year ends', () {
      expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(addDays(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 1));
      expect(addDays(DateTime(2027, 3, 1), -1), DateTime(2027, 2, 28));
    });

    test('knows about leap years', () {
      expect(addDays(DateTime(2028, 2, 28), 1), DateTime(2028, 2, 29));
      expect(addDays(DateTime(2027, 2, 28), 1), DateTime(2027, 3, 1));
    });

    test('drops any time of day and returns midnight', () {
      final result = addDays(DateTime(2026, 9, 26, 15, 30), 1);
      expect(result, DateTime(2026, 9, 27));
      _expectMidnight(result);
    });

    test('adding zero days normalises to midnight of the same day', () {
      expect(addDays(DateTime(2026, 9, 27, 9, 15), 0), DateTime(2026, 9, 27));
    });
  });

  group('formatPrice', () {
    test('formats whole dollars with a dollar sign', () {
      expect(formatPrice(85), r'$85');
    });

    test('groups thousands', () {
      expect(formatPrice(1200), r'$1,200');
      expect(formatPrice(1234567), r'$1,234,567');
    });

    test('shows a free item as \$0, not an empty amount', () {
      expect(formatPrice(0), r'$0');
    });
  });

  group('formatNumber', () {
    test('groups thousands', () {
      expect(formatNumber('1000'), '1,000');
      expect(formatNumber('120000'), '120,000');
      expect(formatNumber('1234567'), '1,234,567');
    });

    test('leaves small numbers alone', () {
      expect(formatNumber('999'), '999');
      expect(formatNumber('0'), '0');
    });

    test('returns non-numeric input unchanged', () {
      expect(formatNumber('abc'), 'abc');
      expect(formatNumber(''), '');
    });
  });

  group('formatDate', () {
    test('formats as day, short month, year', () {
      expect(formatDate(DateTime(2026, 9, 27)), '27 Sep 2026');
      expect(formatDate(DateTime(2026, 1, 5)), '5 Jan 2026');
    });

    test('a late-evening time still shows its own calendar day', () {
      expect(formatDate(DateTime(2026, 4, 5, 23, 59)), '5 Apr 2026');
    });
  });

  group('extractErrorMessage', () {
    test('returns the API message', () {
      expect(
        extractErrorMessage('{"message":"Those dates are not available"}'),
        'Those dates are not available',
      );
    });

    test('trims whitespace around the message', () {
      expect(extractErrorMessage('{"message":"  Booking not found \\n"}'),
          'Booking not found');
    });

    test('never shows a proxy HTML page to the user', () {
      const html = '<html><body>502 Bad Gateway</body></html>';
      final message = extractErrorMessage(html);
      expect(message, isNotEmpty);
      expect(message, isNot(contains('<')));
      expect(extractErrorMessage(html, fallback: 'Try again'), 'Try again');
    });

    test('falls back when the message is missing, blank or not a string', () {
      expect(extractErrorMessage('{"error":"x"}', fallback: 'F'), 'F');
      expect(extractErrorMessage('{"message":""}', fallback: 'F'), 'F');
      expect(extractErrorMessage('{"message":"   "}', fallback: 'F'), 'F');
      expect(extractErrorMessage('{"message":42}', fallback: 'F'), 'F');
      expect(extractErrorMessage('["a","b"]', fallback: 'F'), 'F');
      expect(extractErrorMessage('', fallback: 'F'), 'F');
    });
  });

  group('extractUserIdFromJWT', () {
    // Payload: {"sub":"5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a",
    //           "email":"mia@example.co.nz","n":"~~"}
    // base64url-encoded with the padding stripped, as every JWT is. It
    // contains a '-' (url-safe alphabet) and needs one '=' of padding back.
    const urlSafePayload =
        'eyJzdWIiOiI1YjBjMmY0ZS04ZDFhLTRjN2UtOWYzYi0yYTZkOGUxYzRiN2EiLCJlbWFpbCI6Im1pYUBleGFtcGxlLmNvLm56IiwibiI6In5-In0';
    // Same shape with "n":"a" — needs two '=' of padding back.
    const twoPadPayload =
        'eyJzdWIiOiI1YjBjMmY0ZS04ZDFhLTRjN2UtOWYzYi0yYTZkOGUxYzRiN2EiLCJlbWFpbCI6Im1pYUBleGFtcGxlLmNvLm56IiwibiI6ImEifQ';
    const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

    test('reads the sub claim from an unpadded url-safe payload', () {
      expect(extractUserIdFromJWT('$header.$urlSafePayload.signature'),
          '5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a');
    });

    test('restores two characters of padding', () {
      expect(extractUserIdFromJWT('$header.$twoPadPayload.signature'),
          '5b0c2f4e-8d1a-4c7e-9f3b-2a6d8e1c4b7a');
    });

    test('returns null for something that is not a JWT', () {
      expect(extractUserIdFromJWT('not-a-jwt'), isNull);
      expect(extractUserIdFromJWT('a.b'), isNull);
      expect(extractUserIdFromJWT('$header.!!!.signature'), isNull);
      expect(extractUserIdFromJWT(''), isNull);
    });

    test('returns null when there is no sub claim', () {
      // {"email":"mia@example.co.nz"}
      const noSub = 'eyJlbWFpbCI6Im1pYUBleGFtcGxlLmNvLm56In0';
      expect(extractUserIdFromJWT('$header.$noSub.signature'), isNull);
    });
  });

  group('emailRegex', () {
    test('accepts ordinary addresses', () {
      for (final email in [
        'mia@example.com',
        'mia.tane@boutique.co.nz',
        'mia_tane-1@mail.example.org',
      ]) {
        expect(emailRegex.hasMatch(email), isTrue, reason: email);
      }
    });

    test('accepts plus-addressing (common with Gmail)', () {
      expect(emailRegex.hasMatch('mia+aurae@gmail.com'), isTrue);
    });

    test('accepts top-level domains longer than four letters', () {
      expect(emailRegex.hasMatch('hello@aurae.studio'), isTrue);
      expect(emailRegex.hasMatch('bookings@dresses.boutique'), isTrue);
    });

    test('rejects things that are not addresses', () {
      for (final email in [
        'mia',
        'mia@',
        '@example.com',
        'mia@example',
        'mia tane@example.com',
        'mia@@example.com',
      ]) {
        expect(emailRegex.hasMatch(email), isFalse, reason: email);
      }
    });
  });
}
