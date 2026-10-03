import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/data/models/user.dart';

/// The body of GET /user/:id (viewUser.ts in shine_api).
Map<String, dynamic> _userJson() => {
      'firstName': 'Aroha',
      'lastName': 'Ngata',
      'phoneNumber': '021 555 0199',
      'email': 'aroha@example.co.nz',
      'location': 'Christchurch City',
      'instagram': '@aroha.wears',
      'profilePhotoUrl': 'https://cdn.example.com/users/aroha.jpg',
      'deliveryOption': 'both',
    };

void main() {
  group('User.fromJsonString', () {
    test('parses a profile', () {
      final user = User.fromJsonString(jsonEncode(_userJson()));
      expect(user.firstName, 'Aroha');
      expect(user.lastName, 'Ngata');
      expect(user.phoneNumber, '021 555 0199');
      expect(user.email, 'aroha@example.co.nz');
      expect(user.location, 'Christchurch City');
      expect(user.instagram, '@aroha.wears');
      expect(user.profilePhotoUrl, 'https://cdn.example.com/users/aroha.jpg');
      expect(user.deliveryOption, 'both');
    });

    test('optional profile fields may be null', () {
      final json = _userJson()
        ..['instagram'] = null
        ..['profilePhotoUrl'] = null
        ..['deliveryOption'] = null;
      final user = User.fromJsonString(jsonEncode(json));
      expect(user.instagram, isNull);
      expect(user.profilePhotoUrl, isNull);
      expect(user.deliveryOption, isNull);
    });

    test('optional profile fields may be missing', () {
      final json = _userJson()
        ..remove('instagram')
        ..remove('profilePhotoUrl')
        ..remove('deliveryOption');
      final user = User.fromJsonString(jsonEncode(json));
      expect(user.instagram, isNull);
      expect(user.profilePhotoUrl, isNull);
      expect(user.deliveryOption, isNull);
    });

    test('keeps Korean and macron characters intact', () {
      final json = _userJson()
        ..['firstName'] = '지성'
        ..['location'] = 'Whanganui-a-Tara / Ōtautahi';
      final user = User.fromJsonString(jsonEncode(json));
      expect(user.firstName, '지성');
      expect(user.location, 'Whanganui-a-Tara / Ōtautahi');
    });
  });
}
