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

  /// Statuses that release the dates. Everything else holds them.
  ///
  /// Deliberately a denylist. This used to be an allowlist of the statuses
  /// known at the time — confirmed, pending, active, blocked — which meant any
  /// status added on the server was silently treated as bookable here.
  /// 'returned' fell through exactly that gap: the availability endpoint sent
  /// the range, the calendar dropped it, and the renter could pick dates the
  /// API then refused with a 409 at checkout.
  ///
  /// The endpoint's contract is "ranges during which this dress is spoken for",
  /// so anything that arrives is unavailable unless it is explicitly released.
  /// New statuses now fail closed rather than open.
  static const Set<String> _releasedStatuses = {'cancelled'};

  bool get isUnavailable => !_releasedStatuses.contains(status);
}
