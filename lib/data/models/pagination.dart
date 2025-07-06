class PaginatedResponse<T> {
  final List<T> data;
  final int pageNumber;
  final int totalPages;
  final int totalRows;

  PaginatedResponse({
    required this.data,
    required this.pageNumber,
    required this.totalPages,
    required this.totalRows,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items =
        (json['data'] as List)
            .map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList();

    return PaginatedResponse<T>(
      data: items,
      pageNumber: json['pageNumber'] as int,
      totalPages: json['totalPages'] as int,
      totalRows: json['totalRows'] as int,
    );
  }
}
