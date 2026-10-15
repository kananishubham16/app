import 'package:flutter/foundation.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/repositories/auth_repository.dart';
import 'package:learning_setu/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final StorageService _storageService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepo, this._storageService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulated delay for demo
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = await _authRepo.login(emailOrPhone, password);
      if (_currentUser == null) {
        _error = 'Invalid credentials. Try using "Try Demo" button.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await _storageService.saveCurrentUser(_currentUser!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> demoLogin(UserRole role, {String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = await _authRepo.demoLogin(role, userId: userId);
      if (_currentUser != null) {
        await _storageService.saveCurrentUser(_currentUser!.id);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = 'Demo login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.saveCurrentUser(null);
    _error = null;
    notifyListeners();
  }

  Future<void> tryRestoreSession() async {
    final userId = await _storageService.getCurrentUser();
    if (userId != null) {
      _currentUser = await _authRepo.getCurrentUser();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
