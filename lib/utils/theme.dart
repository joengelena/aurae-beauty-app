import 'package:flutter/material.dart';

// AURAE Color Palette - Minimal, soft, feminine, premium
final themePrimary = Color(0xFFEADFD8);     // Primary: #EADFD8
final themeAccent = Color(0xFFF4C6C3);      // Accent: #F4C6C3
final themeBackground = Color(0xFFFFF8F6);  // Background: #FFF8F6
final themeText = Color(0xFF3A2E2A);        // Text: #3A2E2A

// Legacy/Additional colors
final themePink = Color(0xFFEC4899);        // Primary accent (pink)
final themeLavender = Color(0xFF9333EA);    // Secondary (lavender)
final themeRose = Color(0xFFF43F5E);        // Error/urgent (rose)
final themeSage = Color(0xFF10B981);        // Success (sage green)
final themePeach = Color(0xFFFB923C);       // Warning (soft peach)
final themeCream = themeBackground;         // Background tint (cream)
final themeTaupe = Color(0xFF78716C);       // Secondary text (taupe)

// Legacy color names for backward compatibility during migration
final themeBlue = themeLavender;
final themeGreen = themeSage;
final themeRed = themeRose;
final themeOrange = themePeach;

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: themeBackground,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(
    primary: themeAccent,
    secondary: themePrimary,
    onPrimary: themeText,
    onSecondary: themeText,
    surface: themeBackground,
    onSurface: themeText,
    error: themeRose,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      letterSpacing: 0.5,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      letterSpacing: 0.3,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.2,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black87,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black87,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: themeTaupe,
      height: 1.4,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: themeAccent,
      foregroundColor: themeText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    shadowColor: Colors.black.withOpacity(0.05),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: themeBackground,
    foregroundColor: themeText,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.05),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: themeText,
      fontFamily: 'Poppins',
      letterSpacing: 0.3,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: themeBackground,
    selectedItemColor: themeAccent,
    unselectedItemColor: themeTaupe,
    elevation: 0,
  ),
  dividerColor: Colors.grey.shade300,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: themePrimary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: themePrimary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: themeAccent, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: themeAccent,
    foregroundColor: themeText,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);
