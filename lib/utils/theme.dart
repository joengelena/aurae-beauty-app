import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Color(0xFF1E3A8A),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 14, color: Colors.black87),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.black,
    elevation: 0,
    shadowColor: Colors.black,
  ),
  dividerColor: Colors.grey.shade500,
);
