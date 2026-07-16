import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

class AuthService {
  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(Constants.tokenKey);
    final userData = prefs.getString(Constants.userKey);
    if (_token != null && userData != null) {
      _currentUser = AppUser.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    }
  }

  Future<AppUser> signup({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('${Constants.authEndpoint}/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'displayName': displayName ?? username,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String;
      _currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await _persist();
      return _currentUser!;
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['error'] as String? ?? 'Signup failed');
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Constants.authEndpoint}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String;
      _currentUser = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await _persist();
      return _currentUser!;
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['error'] as String? ?? 'Login failed');
  }

  Future<List<AppUser>> getUsers() async {
    final response = await http.get(
      Uri.parse('${Constants.authEndpoint}/users'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['users'] as List<dynamic>)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch users');
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(Constants.tokenKey, _token!);
    if (_currentUser != null) {
      await prefs.setString(Constants.userKey, jsonEncode(_currentUser!.toJson()));
    }
  }
}
