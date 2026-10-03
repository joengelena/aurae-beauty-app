import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/dress_damage_incident.dart';

/// Shaped like mapDressDamageIncidentDbToObject in shine_api: occurredAt and
/// resolvedAt are DATE columns sent as 'YYYY-MM-DD'.
const _incidentJson = r'''
{
  "id": 9,
  "dressIdFk": 42,
  "bookingIdFk": 311,
  "description": "Small tear at the hem",
  "photoUrls": ["https://cdn.example.com/damage/9/1.jpg"],
  "occurredAt": "2026-09-28",
  "isPublic": true,
  "resolved": true,
  "resolutionNotes": "Repaired by the seamstress",
  "resolvedAt": "2026-10-02",
  "createdAt": "2026-09-28T04:00:00.000Z",
  "updatedAt": "2026-10-02T05:30:00.000Z"
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('DressDamageIncident.fromJson', () {
    test('parses a resolved incident', () {
      final i = DressDamageIncident.fromJson(_decode(_incidentJson));
      expect(i.id, 9);
      expect(i.dressIdFk, 42);
      expect(i.bookingIdFk, 311);
      expect(i.description, 'Small tear at the hem');
      expect(i.photoUrls, ['https://cdn.example.com/damage/9/1.jpg']);
      expect(i.isPublic, isTrue);
      expect(i.resolved, isTrue);
      expect(i.resolutionNotes, 'Repaired by the seamstress');
    });

    test('occurredAt and resolvedAt are the calendar days sent', () {
      final i = DressDamageIncident.fromJson(_decode(_incidentJson));
      expect([i.occurredAt.year, i.occurredAt.month, i.occurredAt.day],
          [2026, 9, 28]);
      final resolvedAt = i.resolvedAt!;
      expect([resolvedAt.year, resolvedAt.month, resolvedAt.day],
          [2026, 10, 2]);
    });

    test('an open incident not tied to a booking parses', () {
      final json = _decode(_incidentJson)
        ..['bookingIdFk'] = null
        ..['photoUrls'] = <dynamic>[]
        ..['isPublic'] = false
        ..['resolved'] = false
        ..['resolutionNotes'] = null
        ..['resolvedAt'] = null;
      final i = DressDamageIncident.fromJson(json);
      expect(i.bookingIdFk, isNull);
      expect(i.photoUrls, isEmpty);
      expect(i.resolved, isFalse);
      expect(i.resolutionNotes, isNull);
      expect(i.resolvedAt, isNull);
    });

    test('missing photo list means no photos', () {
      final json = _decode(_incidentJson)..remove('photoUrls');
      expect(DressDamageIncident.fromJson(json).photoUrls, isEmpty);
    });
  });

  group('DressDamageIncident.copyWith', () {
    test('resolving keeps everything else', () {
      final json = _decode(_incidentJson)
        ..['resolved'] = false
        ..['resolutionNotes'] = null
        ..['resolvedAt'] = null;
      final open = DressDamageIncident.fromJson(json);
      final fixed = open.copyWith(
        resolved: true,
        resolutionNotes: 'Mended',
        resolvedAt: DateTime(2026, 10, 3),
      );
      expect(fixed.resolved, isTrue);
      expect(fixed.resolutionNotes, 'Mended');
      expect(fixed.resolvedAt, DateTime(2026, 10, 3));
      expect(fixed.id, open.id);
      expect(fixed.description, open.description);
      expect(fixed.occurredAt, open.occurredAt);
      expect(open.resolved, isFalse);
    });
  });
}
