import '../models/user.dart';
import 'api_service.dart';

class UserService {
  UserService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<UserModel>> fetchAdmins({String role = 'staff'}) async {
    final response = await _apiService.get(
      '/users/admins',
      queryParameters: {'role': role},
    );
    final data = response.data as List<dynamic>;
    return data.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<UserModel> createAdmin({
    required String name,
    required String email,
    required String password,
    String role = 'staff',
  }) async {
    final response = await _apiService.post(
      '/users/admins',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['admin'] as Map<String, dynamic>);
  }

  Future<UserModel> updateAdmin({
    required String id,
    String? name,
    String? email,
    String? password,
    bool? isActive,
    String? role,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }
    if (isActive != null) payload['isActive'] = isActive;
    if (role != null) payload['role'] = role;

    final response = await _apiService.patch(
      '/users/admins/$id',
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['admin'] as Map<String, dynamic>);
  }

  Future<UserModel> updateMe({
    String? name,
    String? email,
    String? password,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final response = await _apiService.patch('/users/me', data: payload);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
