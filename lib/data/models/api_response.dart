class ApiResponse<T> {
  final T? data;

  final String? error;

  bool get isSuccess => error == null;

  ApiResponse._({this.data, this.error});

  factory ApiResponse.success(T data) => ApiResponse._(data: data);

  factory ApiResponse.failure(String error) => ApiResponse._(error: error);
}
