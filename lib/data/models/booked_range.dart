class BookedRange {
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const BookedRange({
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory BookedRange.fromJson(Map<String, dynamic> json) {
    return BookedRange(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String? ?? 'confirmed',
    );
  }

  bool get isUnavailable =>
      status == 'confirmed' || status == 'pending' || status == 'active' || status == 'blocked';
}
