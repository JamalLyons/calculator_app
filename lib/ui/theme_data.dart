import 'package:flutter/material.dart';

/// App theme definitions supporting seamless Light and Dark modes
/// with WCAG-compliant high-contrast surface colors.
class AppThemes {
  // Light Theme Colors
  static const Color lightBg = Color(0xFFF3F4F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDisplayBg = Color(0xFFE5E7EB);
  static const Color lightNumberBtn = Color(0xFFFFFFFF);
  static const Color lightNumberText = Color(0xFF111827);
  static const Color lightOperatorBtn = Color(0xFF3B82F6); // Blue
  static const Color lightOperatorText = Color(0xFFFFFFFF);
  static const Color lightActionBtn = Color(0xFFE5E7EB); // Gray
  static const Color lightActionText = Color(0xFF1F2937);
  static const Color lightEqualsBtn = Color(0xFF10B981); // Emerald
  static const Color lightEqualsText = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkDisplayBg = Color(0xFF0F172A);
  static const Color darkNumberBtn = Color(0xFF374151);
  static const Color darkNumberText = Color(0xFFF9FAFB);
  static const Color darkOperatorBtn = Color(0xFF2563EB); // Vivid Blue
  static const Color darkOperatorText = Color(0xFFFFFFFF);
  static const Color darkActionBtn = Color(0xFF4B5563);
  static const Color darkActionText = Color(0xFFF3F4F6);
  static const Color darkEqualsBtn = Color(0xFF059669); // Deep Emerald
  static const Color darkEqualsText = Color(0xFFFFFFFF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: ColorScheme.light(
      primary: lightOperatorBtn,
      secondary: lightEqualsBtn,
      surface: lightSurface,
      onSurface: lightNumberText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightNumberText,
      elevation: 0,
      centerTitle: false,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.dark(
      primary: darkOperatorBtn,
      secondary: darkEqualsBtn,
      surface: darkSurface,
      onSurface: darkNumberText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkNumberText,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
