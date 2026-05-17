import 'package:flutter/material.dart';

class AppTheme {
  static const List<Color> noteColors = [
    Color(0xFFF8F9FA), // White
    Color(0xFFFFEEBA), // Yellow
    Color(0xFFD4F1C4), // Green
    Color(0xFFBBDEFB), // Blue
    Color(0xFFF8BBD0), // Pink
    Color(0xFFE1BEE7), // Purple
    Color(0xFFFFCCBC), // Orange
    Color(0xFFB2EBF2), // Cyan
  ];

  static const List<Color> noteColorsDark = [
    Color(0xFF2C2C2C),
    Color(0xFF5C4E00),
    Color(0xFF1A3D0F),
    Color(0xFF0D2E4D),
    Color(0xFF4D0E26),
    Color(0xFF2E0A4D),
    Color(0xFF4D2200),
    Color(0xFF004D5A),
  ];

  static const List<String> categories = [
    'General',
    'Work',
    'Personal',
    'Ideas',
    'Shopping',
    'Health',
    'Travel',
    'Study',
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1B1F),
  );
}

class AppConstants {
  static const String appName = 'NoteFlow';
  static const Duration animationDuration = Duration(milliseconds: 300);
}
