import '../models/user.dart';
import 'api_service.dart';

class AuthResult {
  AuthResult({required this.token, required this.user});

  final String token;
  final UserModel user;
}

class AuthService {
  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? district,
  }) async {
    final response = await _apiService.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (district != null && district.isNotEmpty) 'district': district,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _apiService.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resendVerification({required String email}) async {
    await _apiService.post(
      '/auth/resend-verification',
      data: {'email': email},
    );
  }

  Future<void> verifyEmail({required String token}) async {
    await _apiService.get(
      '/auth/verify-email',
      queryParameters: {'token': token},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _apiService.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
      },
    );
  }
}
