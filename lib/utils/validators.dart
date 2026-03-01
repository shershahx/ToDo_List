class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final trimmed = value.trim();

    // Must contain exactly one '@'
    if (!trimmed.contains('@') || trimmed.split('@').length != 2) {
      return 'Email must contain a single @ symbol';
    }

    final parts = trimmed.split('@');
    final local = parts[0]; // part before @
    final domain = parts[1]; // part after @

    if (local.isEmpty) {
      return 'Email username cannot be empty';
    }

    if (!domain.contains('.')) {
      return 'Email domain must contain a dot (e.g. gmail.com)';
    }

    // Check that domain doesn't start or end with a dot
    if (domain.startsWith('.') || domain.endsWith('.')) {
      return 'Please enter a valid email address';
    }

    // Final regex check for allowed characters
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
