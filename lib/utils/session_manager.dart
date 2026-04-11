/// Manages login session persistence using Firebase Auth state.
///
/// Checks [FirebaseAuth.currentUser] to determine if the user is logged in.
/// Tracks the login method ('email' or 'google') locally so logout can call
/// the correct sign-out flow.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/utils/google_auth_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _methodKey = 'login_method'; // 'email' or 'google'

  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  /// The login method ('email' or 'google').
  String? loginMethod;

  /// The email of the currently logged-in user.
  String? get currentEmail => _auth.currentUser?.email;

  Future<void> saveSession(String email, {String method = 'email'}) async {
    await _storage.write(key: _methodKey, value: method);
    loginMethod = method;
  }

  Future<bool> isLoggedIn() async {
    final loggedIn = _auth.currentUser != null;
    if (loggedIn) {
      loginMethod = await _storage.read(key: _methodKey) ?? 'email';
    }
    return loggedIn;
  }

  Future<String?> getEmail() async {
    return _auth.currentUser?.email;
  }

  Future<void> clearSession() async {
    // Sign out of Google if that was the login method
    if (loginMethod == 'google') {
      await GoogleAuthService().signOut();
    } else {
      await _auth.signOut();
    }
    await _storage.delete(key: _methodKey);
    loginMethod = null;
  }
}
