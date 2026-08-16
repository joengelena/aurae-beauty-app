import 'package:flutter/material.dart';

// AURAE Color Palette - Minimal, soft, feminine, premium
final themePrimary = Color(0xFFEADFD8);     // Primary: #EADFD8
final themeAccent = Color(0xFFF4C6C3);      // Accent: #F4C6C3
// First Blush darkened for use as text/icon color — #F4C6C3 on white is ~1.5:1
// contrast (fails WCAG AA). Same hue family, ~4.9:1 against white/Petal White.
final themeAccentInk = Color(0xFFAE5751);
final themeBackground = Color(0xFFFFF8F6);  // Background: #FFF8F6
final themeText = Color(0xFF3A2E2A);        // Text: #3A2E2A

// Semantic colors
final themeLavender = Color(0xFF9333EA);    // Info (lavender) — used via themeBlue alias
final themeRose = Color(0xFFF43F5E);        // Error/urgent (rose)
final themeSage = Color(0xFF10B981);        // Success (sage green)
final themePeach = Color(0xFFFB923C);       // Warning (soft peach)
final themeTaupe = Color(0xFF78716C);       // Secondary text (taupe)

// Muted neutral surface — chip backgrounds, photo placeholders, icon
// squares. Per the Tinted-Neutral Rule, this is the one shared near-white
// tint; don't hand-type a new one (previously drifted between #F5EFED and
// #F5F0ED depending on the file).
final themeSurfaceMuted = Color(0xFFF5EFED);

// Dress color palette — maps color name strings to display colors
const Map<String, Color> dressColorMap = {
  'Black':     Color(0xFF1C1C1C),
  'White':     Color(0xFFF0EDE8),
  'Ivory':     Color(0xFFFFF0C8),
  'Blush':     Color(0xFFE8B4B8),
  'Pink':      Color(0xFFF472B6),
  'Red':       Color(0xFFDC2626),
  'Burgundy':  Color(0xFF800020),
  'Navy':      Color(0xFF1E3A5F),
  'Blue':      Color(0xFF3B82F6),
  'Sage':      Color(0xFF84A98C),
  'Green':     Color(0xFF22C55E),
  'Emerald':   Color(0xFF059669),
  'Gold':      Color(0xFFD4AF37),
  'Silver':    Color(0xFFB8B8B8),
  'Champagne': Color(0xFFF7E7CE),
  'Lilac':     Color(0xFFB39DDB),
  'Nude':      Color(0xFFE5C9B0),
};

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
      color: themeText,
      letterSpacing: 0.5,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: themeText,
      letterSpacing: 0.3,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: themeText,
      letterSpacing: 0.2,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: themeText,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: themeText,
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
      disabledBackgroundColor: Color(0xFFDDD4CF),
      disabledForegroundColor: Color(0xFFA89E99),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha:0.1),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: themeAccent,
      foregroundColor: themeText,
      disabledBackgroundColor: Color(0xFFDDD4CF),
      disabledForegroundColor: Color(0xFFA89E99),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha:0.1),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: themeText,
      side: BorderSide(color: Color(0xFFEADFD8), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: themeAccentInk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
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
    shadowColor: Colors.black.withValues(alpha:0.05),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: themeBackground,
    foregroundColor: themeText,
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha:0.05),
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: themeText,
      fontFamily: 'Poppins',
      letterSpacing: 0.3,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: themeBackground,
    selectedItemColor: themeAccentInk,
    unselectedItemColor: themeTaupe,
    elevation: 0,
  ),
  dividerColor: const Color(0xFFE0D5D0),
  // Material 3 derives modal/sheet backgrounds from ColorScheme's
  // surfaceContainer* roles, which this ColorScheme.light() call never sets —
  // they silently fall back to Flutter's cool lavender-gray M3 defaults,
  // completely disconnected from the warm Petal White palette. Pinning the
  // background explicitly (and zeroing surfaceTintColor, M3's automatic
  // elevation color-wash) keeps every bottom sheet — filters, sort, pickers —
  // the same warm tone as the rest of the app instead of a mismatched white.
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: themeBackground,
    modalBackgroundColor: themeBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),
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
