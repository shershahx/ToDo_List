import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _loggedInKey = 'is_logged_in';
  static const String _emailKey = 'logged_in_email';

  /// The email of the currently logged-in user (null if not logged in).
  /// Populated by [saveSession] and [loadSession].
  String? currentEmail;

  final _storage = const FlutterSecureStorage();

  Future<void> saveSession(String email) async {
    await _storage.write(key: _loggedInKey, value: 'true');
    await _storage.write(key: _emailKey, value: email);
    currentEmail = email;
  }

  Future<bool> isLoggedIn() async {
    final loggedInStr = await _storage.read(key: _loggedInKey);
    final loggedIn = loggedInStr == 'true';
    if (loggedIn) {
      currentEmail = await _storage.read(key: _emailKey);
    }
    return loggedIn;
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _loggedInKey);
    await _storage.delete(key: _emailKey);
    currentEmail = null;
  }
}
