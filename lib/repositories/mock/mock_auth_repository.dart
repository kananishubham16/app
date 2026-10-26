import 'package:learning_setu/mock_data/mock_data.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<UserModel?> login(String emailOrPhone, String password, {UserRole? role}) async {
    final query = emailOrPhone.trim().toLowerCase();
    final digits = emailOrPhone.replaceAll(RegExp(r'\D'), '');
    UserModel? user;

    // 1. Exact email match
    try {
      user = MockData.demoUsers.firstWhere(
        (u) => u.email.toLowerCase() == query,
      );
    } catch (_) {}

    // 2. Phone match by comparing normalized trailing digits (e.g. 10-digit mobile)
    if (user == null && digits.isNotEmpty) {
      try {
        user = MockData.demoUsers.firstWhere((u) {
          final uDigits = u.phone.replaceAll(RegExp(r'\D'), '');
          return uDigits.endsWith(digits) || digits.endsWith(uDigits);
        });
      } catch (_) {}
    }

    // 3. Fallback: if role is specified, log in as that role's default demo user
    if (user == null && role != null) {
      try {
        user = MockData.demoUsers.firstWhere((u) => u.role == role);
      } catch (_) {}
    }

    // 4. Fallback: if email or query contains role hints
    if (user == null) {
      if (query.contains('teach')) {
        user = MockData.demoUsers.firstWhere((u) => u.role == UserRole.teacher);
      } else if (query.contains('princ')) {
        user = MockData.demoUsers.firstWhere((u) => u.role == UserRole.principal);
      } else if (query.contains('brc')) {
        user = MockData.demoUsers.firstWhere((u) => u.role == UserRole.brc);
      } else if (query.contains('parent')) {
        user = MockData.demoUsers.firstWhere((u) => u.role == UserRole.parent);
      }
    }

    // 5. Ultimate demo fallback: default to first demo user
    user ??= MockData.demoUsers.first;

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
