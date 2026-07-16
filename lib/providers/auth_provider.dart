import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  AuthService get authService => _authService;
  AppUser? get currentUser => _authService.currentUser;
  String? get token => _authService.token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get error => _error;

  Future<void> init() async {
    await _authService.init();
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.login(email: email, password: password);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signup(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
