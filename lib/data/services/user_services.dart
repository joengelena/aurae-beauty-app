import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';
import 'package:motorix_app/data/models/api_response.dart';
import 'package:motorix_app/data/models/user.dart';

class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<ApiResponse> signUp(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    http.Response response = await apiClient.post('/user/signup', {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    });

    if (response.statusCode != HttpStatus.created) {
      return ApiResponse.failure('Failed to sign up');
    }

    return ApiResponse.success(response.body);
  }

  Future<ApiResponse> signIn(String email, String password) async {
    http.Response response = await apiClient.post('/user/signin', {
      'email': email,
      'password': password,
    });

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure(response.body);
    }

    return ApiResponse.success(response.body);
  }

  Future<ApiResponse> signOut() async {
    http.Response response = await apiClient.post('/user/signout', {});

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure('Failed to sign out');
    }

    return ApiResponse.success(response.body);
  }

  Future<ApiResponse<User>> getUserWithId(String userId) async {
    http.Response response = await apiClient.get('/users/$userId');

    if (response.statusCode != HttpStatus.ok) {
      return ApiResponse.failure('Failed to get user');
    }

    return ApiResponse<User>.success(User.fromJsonString(response.body));
  }
}
