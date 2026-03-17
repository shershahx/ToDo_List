import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure user store for registered accounts.
class UserStore {
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  final _storage = const FlutterSecureStorage();
  static const String _usersKey = 'secure_users';

  // email → password mapping
  Map<String, String> _users = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final data = await _storage.read(key: _usersKey);
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        _users = decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {
        _users = {};
      }
    }
    _initialized = true;
  }

  Future<void> _save() async {
    await _storage.write(key: _usersKey, value: jsonEncode(_users));
  }

  Future<void> register(String email, String password) async {
    await init();
    _users[email.trim().toLowerCase()] = password;
    await _save();
  }

  Future<bool> authenticate(String email, String password) async {
    await init();
    final key = email.trim().toLowerCase();
    return _users.containsKey(key) && _users[key] == password;
  }

  Future<bool> emailExists(String email) async {
    await init();
    return _users.containsKey(email.trim().toLowerCase());
  }

  Future<void> updatePassword(String email, String newPassword) async {
    await init();
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      _users[key] = newPassword;
      await _save();
    }
  }
}
