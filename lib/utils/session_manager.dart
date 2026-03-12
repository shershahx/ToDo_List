import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _loggedInKey = 'is_logged_in';
  static const String _emailKey = 'logged_in_email';

  /// The email of the currently logged-in user (null if not logged in).
  /// Populated by [saveSession] and [loadSession].
  String? currentEmail;

  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_emailKey, email);
    currentEmail = email;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_loggedInKey) ?? false;
    if (loggedIn) {
      currentEmail = prefs.getString(_emailKey);
    }
    return loggedIn;
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_emailKey);
    currentEmail = null;
  }
}
