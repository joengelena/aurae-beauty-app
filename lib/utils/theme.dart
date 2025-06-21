import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Helvetica',
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Color(0xFF1E3A8A), // rose red accent
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
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
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
