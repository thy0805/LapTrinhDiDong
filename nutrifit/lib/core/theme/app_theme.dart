import 'package:flutter/material.dart';

class AppTheme {
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

  static final ThemeData darkAbyss = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF38BDF8),
    scaffoldBackgroundColor: const Color(0xFF000C18),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B162C),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF38BDF8),
      secondary: Color(0xFF0EA5E9),
      surface: Color(0xFF0B162C),
      onSurface: Colors.white,
      onPrimary: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFE2E8F0)),
    ),
  );

  static final ThemeData oceanBlue = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0284C7),
    scaffoldBackgroundColor: const Color(0xFFF0F6FC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0284C7),
      secondary: Color(0xFF38BDF8),
      surface: Colors.white,
    ),
  );
}
