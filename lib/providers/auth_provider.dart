import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;
  final ApiService _apiService = ApiService();
  final _userService = UserService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;
  String? get errorMessage => _error;

  bool get isStaff => _user?.role == 'staff';
  bool get isAdmin => _user?.role == 'admin';
  bool get isDirector => _user?.role == 'director';

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user');

    if (storedToken != null && storedUser != null) {
      final parsed = jsonDecode(storedUser) as Map<String, dynamic>;
      _token = storedToken;
      _user = UserModel.fromJson(parsed);
      _apiService.setToken(storedToken);
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email: email, password: password);
      await _persistSession(result);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? district,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        district: district,
      );
      await _persistSession(result);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _apiService.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    notifyListeners();
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await _authService.requestPasswordReset(email: email);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerification(String email) async {
    try {
      await _authService.resendVerification(email: email);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailToken(String token) async {
    try {
      await _authService.verifyEmail(token: token);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _authService.resetPassword(token: token, password: password);
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    _setLoading(true);
    try {
      final updated = await _userService.updateMe(
        name: name,
        email: email,
        password: password,
      );
      _user = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(updated.toJson()));
      notifyListeners();
      return true;
    } catch (err) {
      _error = _mapError(err);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _persistSession(AuthResult result) async {
    _user = result.user;
    _token = result.token;
    _apiService.setToken(result.token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', result.token);
    await prefs.setString('auth_user', jsonEncode(result.user.toJson()));
    notifyListeners();
  }

  String _mapError(Object err) {
    if (kDebugMode) {
      print('Auth error: $err');
    }

    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return err.message ?? 'Сервер қатесі';
    }

    if (err is Exception) {
      return err.toString().replaceAll('Exception: ', '');
    }
    return 'Қате пайда болды. Кейінірек қайталап көріңіз.';
  }
}
