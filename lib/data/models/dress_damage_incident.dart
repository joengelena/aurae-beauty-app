class DressDamageIncident {
  final int id;
  final int dressIdFk;
  final int? bookingIdFk;
  final String description;
  final List<String> photoUrls;
  final DateTime occurredAt;
  final bool isPublic;
  final bool resolved;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DressDamageIncident({
    required this.id,
    required this.dressIdFk,
    this.bookingIdFk,
    required this.description,
    this.photoUrls = const [],
    required this.occurredAt,
    this.isPublic = false,
    this.resolved = false,
    this.resolutionNotes,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  DressDamageIncident copyWith({
    bool? resolved,
    String? resolutionNotes,
    DateTime? resolvedAt,
  }) {
    return DressDamageIncident(
      id: id,
      dressIdFk: dressIdFk,
      bookingIdFk: bookingIdFk,
      description: description,
      photoUrls: photoUrls,
      occurredAt: occurredAt,
      isPublic: isPublic,
      resolved: resolved ?? this.resolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DressDamageIncident.fromJson(Map<String, dynamic> json) {
    return DressDamageIncident(
      id: json['id'] as int,
      dressIdFk: json['dressIdFk'] as int,
      bookingIdFk: json['bookingIdFk'] as int?,
      description: json['description'] as String? ?? '',
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      resolved: json['resolved'] as bool? ?? false,
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
