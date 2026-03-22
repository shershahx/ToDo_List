/// Manages login session persistence using encrypted storage.
///
/// Tracks whether the user is logged in, their email, and whether they
/// signed in via email/password or Google — so logout can call the
/// correct sign-out flow.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/utils/google_auth_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _loggedInKey = 'is_logged_in';
  static const String _emailKey = 'logged_in_email';
  static const String _methodKey = 'login_method'; // 'email' or 'google'

  /// The email of the currently logged-in user (null if not logged in).
  String? currentEmail;

  /// The login method ('email' or 'google').
  String? loginMethod;

  final _storage = const FlutterSecureStorage();

  Future<void> saveSession(String email, {String method = 'email'}) async {
    await _storage.write(key: _loggedInKey, value: 'true');
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _methodKey, value: method);
    currentEmail = email;
    loginMethod = method;
  }

  Future<bool> isLoggedIn() async {
    final loggedInStr = await _storage.read(key: _loggedInKey);
    final loggedIn = loggedInStr == 'true';
    if (loggedIn) {
      currentEmail = await _storage.read(key: _emailKey);
      loginMethod = await _storage.read(key: _methodKey) ?? 'email';
    }
    return loggedIn;
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> clearSession() async {
    // Sign out of Google if that was the login method
    if (loginMethod == 'google') {
      await GoogleAuthService().signOut();
    }
    await _storage.delete(key: _loggedInKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _methodKey);
    currentEmail = null;
    loginMethod = null;
  }
}
