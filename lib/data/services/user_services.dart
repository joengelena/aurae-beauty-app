import 'package:http/http.dart' as http;
import 'package:motorix_app/data/api_client.dart';

class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<http.Response> signUp(
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

    return response;
  }

  Future<http.Response> signIn(String email, String password) async {
    http.Response response = await apiClient.post('/user/signin', {
      'email': email,
      'password': password,
    });

    return response;
  }

  Future<http.Response> signOut() async {
    http.Response response = await apiClient.post('/user/signout', {});

    return response;
  }

  Future<http.Response> getUserWithId(String userId) async {
    http.Response response = await apiClient.post('/user/$userId', {});

    return response;
  }
}
