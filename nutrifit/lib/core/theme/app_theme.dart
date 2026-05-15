import 'package:flutter/material.dart';

class AppTheme {
  // Pink Light Theme
  static final ThemeData pinkLight = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFC050F6),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFC050F6),
      secondary: Color(0xFFEEA4CE),
      surface: Colors.white,
    ),
  );

  // Pink Dark Theme
  static final ThemeData pinkDark = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFC050F6),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFC050F6),
      secondary: Color(0xFFEEA4CE),
      surface: Color(0xFF1E1E1E),
    ),
  );

  // Blue Light Theme
  static final ThemeData blueLight = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2196F3),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF64B5F6),
      surface: Colors.white,
    ),
  );

  // Blue Dark Theme
  static final ThemeData blueDark = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2196F3),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFF1E1E1E),
    ),
  );
}
