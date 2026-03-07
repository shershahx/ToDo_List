// Simple in-memory user store for registered accounts.
// This will be replaced with a proper database in later weeks.
class UserStore {
  // Singleton so it persists across screen navigations
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  // email → password mapping for registered users
  final Map<String, String> _users = {};

  void register(String email, String password) {
    _users[email.trim().toLowerCase()] = password;
  }

  bool authenticate(String email, String password) {
    final key = email.trim().toLowerCase();
    return _users.containsKey(key) && _users[key] == password;
  }

  bool emailExists(String email) {
    return _users.containsKey(email.trim().toLowerCase());
  }

  void updatePassword(String email, String newPassword) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      _users[key] = newPassword;
    }
  }
}
