import 'package:learning_setu/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String emailOrPhone, String password);
  Future<UserModel?> demoLogin(UserRole role, {String? userId});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
