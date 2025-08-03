class PublicProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  PublicProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  /// Creates a new Listing from a JSON map.
  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}
