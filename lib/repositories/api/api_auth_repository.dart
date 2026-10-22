import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/repositories/auth_repository.dart';
import 'package:learning_setu/repositories/api/api_client.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient client;
  UserModel? _currentUser;

  ApiAuthRepository({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<UserModel?> login(String emailOrPhone, String password) async {
    try {
      final res = await client.post('auth/login', body: {
        'emailOrPhone': emailOrPhone,
        'password': password,
      });
      if (res != null) {
        _currentUser = UserModel.fromJson(res as Map<String, dynamic>);
        return _currentUser;
      }
    } catch (_) {
      return null;
    }
    return null;
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
        _currentUser = UserModel.fromJson(res as Map<String, dynamic>);
        return _currentUser;
      }
    } catch (_) {
      return null;
    }
    return null;
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
