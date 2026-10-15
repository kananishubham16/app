import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel?> login(String emailOrPhone, String password) async {
    final query = emailOrPhone.trim().toLowerCase();
    final cleanPhone = emailOrPhone.replaceAll(RegExp(r'\s+'), '');
    UserModel? user;
    try {
      user = MockData.demoUsers.firstWhere(
        (u) =>
            u.email.toLowerCase() == query ||
            u.phone.replaceAll(RegExp(r'\s+'), '') == cleanPhone,
      );
    } catch (_) {
      user = null;
    }
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel?> demoLogin(UserRole role, {String? userId}) async {
    UserModel? user;
    try {
      if (userId != null) {
        user = MockData.demoUsers.firstWhere((u) => u.id == userId);
      } else {
        user = MockData.demoUsers.firstWhere((u) => u.role == role);
      }
    } catch (_) {
      user = null;
    }
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
