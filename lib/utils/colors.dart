import 'package:flutter/material.dart';

// Dark mode productivity color palette
class AppColors {
  static const Color primary = Color(0xFF6366F1);     // Indigo
  static const Color background = Color(0xFF0F172A);   // Dark navy
  static const Color card = Color(0xFF1E293B);         // Slate card
  static const Color accent = Color(0xFF22D3EE);       // Cyan
  static const Color success = Color(0xFF10B981);      // Green for completed
  static const Color textPrimary = Color(0xFFE2E8F0);  // Light gray text
  static const Color textSecondary = Color(0xFF94A3B8); // Muted text
  static const Color error = Color(0xFFEF4444);        // Red for errors
  static const Color inputFill = Color(0xFF1E293B);    // Same as card for inputs
  static const Color skyBlue = Color(0xFF60A5FA);      // Blue for sign-up accents

  // Task category colors
  static const Color categoryWork = Color(0xFF3B82F6);
  static const Color categoryPersonal = Color(0xFF10B981);
  static const Color categoryUrgent = Color(0xFFEF4444);

  static const Map<String, Color> categoryColors = {
    'work': categoryWork,
    'personal': categoryPersonal,
    'urgent': categoryUrgent,
  };

  static const Map<String, String> categoryLabels = {
    'none': 'None',
    'work': 'Work',
    'personal': 'Personal',
    'urgent': 'Urgent',
  };

  static const Map<String, IconData> categoryIcons = {
    'work': Icons.work_outline_rounded,
    'personal': Icons.person_outline_rounded,
    'urgent': Icons.priority_high_rounded,
  };
}
