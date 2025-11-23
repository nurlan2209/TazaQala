import '../models/user.dart';
import 'api_service.dart';

class UserService {
  UserService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<UserModel>> fetchAdmins() async {
    final response = await _apiService.get('/users/admins');
    final data = response.data as List<dynamic>;
    return data.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<UserModel> createAdmin({
    required String name,
    required String email,
    required String password,
    required String district,
  }) async {
    final response = await _apiService.post(
      '/users/admins',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'district': district,
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
    String? district,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }
    if (district != null) payload['district'] = district;
    if (isActive != null) payload['isActive'] = isActive;

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
