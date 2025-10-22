import 'dart:convert';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromJsonString(String jsonString) {
    Map<String, dynamic> decodedJson = json.decode(jsonString);

    return User(
      firstName: decodedJson['firstName'] as String,
      lastName: decodedJson['lastName'] as String,
      email: decodedJson['email'] as String,
      phoneNumber: decodedJson['phoneNumber'] as String,
    );
  }
}
