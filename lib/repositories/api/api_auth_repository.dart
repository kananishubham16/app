import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/repositories/auth_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient client;
  final MockAuthRepository _mockFallback = MockAuthRepository();
  UserModel? _currentUser;

  ApiAuthRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<UserModel?> login(String emailOrPhone, String password, {UserRole? role}) async {
    try {
      final res = await client.post('auth/login', body: {
        'email': emailOrPhone,
        'emailOrPhone': emailOrPhone,
        'password': password,
      });
      if (res != null) {
        final userData = (res is Map && res['data'] is Map)
            ? (res['data'] as Map).cast<String, dynamic>()
            : (res as Map).cast<String, dynamic>();
        _currentUser = UserModel.fromJson(userData);
        return _currentUser;
      }
    } catch (_) {
      // Backend unreachable or offline, fallback to robust mock auth
      _currentUser = await _mockFallback.login(emailOrPhone, password, role: role);
      return _currentUser;
    }
    _currentUser = await _mockFallback.login(emailOrPhone, password, role: role);
    return _currentUser;
  }

  @override
  Future<UserModel?> demoLogin(UserRole role, {String? userId}) async {
    try {
      final payload = <String, dynamic>{'role': role.name};
      if (userId != null) {
        payload['userId'] = userId;
      }
      final res = await client.post('auth/demo-login', body: payload);
      if (res != null) {
        final userData = (res is Map && res['data'] is Map)
            ? (res['data'] as Map).cast<String, dynamic>()
            : (res as Map).cast<String, dynamic>();
        _currentUser = UserModel.fromJson(userData);
        return _currentUser;
      }
    } catch (_) {
      // Backend unreachable or offline, fallback to robust mock auth
      _currentUser = await _mockFallback.demoLogin(role, userId: userId);
      return _currentUser;
    }
    _currentUser = await _mockFallback.demoLogin(role, userId: userId);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      await client.post('auth/logout');
    } catch (_) {}
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
