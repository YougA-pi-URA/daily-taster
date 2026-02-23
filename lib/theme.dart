import 'package:flutter/material.dart';
import '../models/task.dart';

/// App-wide color constants matching the dark navy design (Design A)
class AppColors {
  // Base
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);
  static const Color cardBg = Color(0xFF1E293B);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF8B9CB8);

  // Section accent colors
  static const Color doingAccent = Color(0xFFF59E0B); // amber
  static const Color stockAccent = Color(0xFF3B82F6); // blue
  static const Color reviewAccent = Color(0xFF06B6D4); // cyan
  static const Color doneAccent = Color(0xFF10B981); // green

  // Status tag colors
  static const Color freshTag = Color(0xFF22C55E); // green
  static const Color holdTag = Color(0xFF6B7280); // gray
  static const Color returnedTag = Color(0xFFA855F7); // purple

  // Priority colors
  static const Color urgentPriority = Color(0xFFEF4444); // red
  static const Color normalPriority = Color(0xFFF59E0B); // amber
  static const Color lowPriority = Color(0xFF6B7280); // gray

  // Misc
  static const Color divider = Color(0xFF334155);
  static const Color inputBg = Color(0xFF1E293B);
  static const Color inputBorder = Color(0xFF475569);

  /// Get accent color for a section
  static Color sectionAccent(String section) {
    switch (section) {
      case 'doing':
        return doingAccent;
      case 'stock':
        return stockAccent;
      case 'review':
        return reviewAccent;
      case 'done':
        return doneAccent;
      default:
        return textSecondary;
    }
  }

  /// Get color for a task status tag
  static Color statusTagColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.fresh:
        return freshTag;
      case TaskStatus.hold:
        return holdTag;
      case TaskStatus.returned:
        return returnedTag;
      case TaskStatus.doing:
        return doingAccent;
      case TaskStatus.review:
        return reviewAccent;
      case TaskStatus.done:
        return doneAccent;
    }
  }

  /// Get color for priority
  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return urgentPriority;
      case TaskPriority.normal:
        return normalPriority;
      case TaskPriority.low:
        return lowPriority;
    }
  }
}

/// Build the dark navy theme
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.doingAccent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.doingAccent,
      secondary: AppColors.stockAccent,
      surface: AppColors.surface,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.doingAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 18),
    dividerColor: AppColors.divider,
    splashColor: Colors.white10,
    highlightColor: Colors.white10,
  );
}
