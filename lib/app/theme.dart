import 'package:flutter/material.dart';

class AppTheme {
  // Color constants
  static const Color backgroundColor = Color(0xFF0B0E11);
  static const Color primaryColor = Color(0xFF2D7BFF);
  static const Color accentColor = Color(0xFF39FF14);

  // Additional dark theme colors
  static const Color surfaceColor = Color(0xFF1A1D21);
  static const Color onSurfaceColor = Color(0xFFFFFFFF);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        surface: backgroundColor,
        primary: primaryColor,
        secondary: accentColor,
        onSurface: onSurfaceColor,
        onPrimary: onPrimaryColor,
        onSecondary: backgroundColor,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
      ),

      // Card
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 4,
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: onSurfaceColor,
        ),
        bodyMedium: TextStyle(
          color: onSurfaceColor,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: onSurfaceColor,
      ),
    );
  }
}
