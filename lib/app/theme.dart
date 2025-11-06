import 'package:flutter/material.dart';
import 'dart:ui';

/// Hockey Gym Global Style V2
/// Modern, athletic design inspired by Fitbod × EA Sports × Apple Fitness
/// Dark, precise, hockey-themed with strategic glassmorphism
class AppTheme {
  // ============================================================================
  // COLOR SCHEME - Hockey Gym V2
  // ============================================================================
  
  /// Deep dark background - primary app background
  static const Color backgroundColor = Color(0xFF050B18);
  
  /// Slightly lighter surface color for cards and containers
  static const Color surfaceColor = Color(0xFF0D1323);
  
  /// Hockey ice blue - primary brand color
  static const Color primaryColor = Color(0xFF00B4FF);
  
  /// Gold accent for highlights and achievements
  static const Color accentGold = Color(0xFFFFB84D);
  
  /// Success green
  static const Color success = Color(0xFF4CAF50);
  
  /// Warning amber
  static Color warning = Colors.amber.shade300;
  
  /// Error red
  static const Color error = Colors.red;
  
  /// White for text on dark backgrounds
  static const Color onSurfaceColor = Color(0xFFFFFFFF);
  
  /// White for text on primary color
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  
  /// Secondary accent (keeping backward compatibility)
  static const Color accentColor = primaryColor;
  
  // ============================================================================
  // GLASSMORPHISM COLORS
  // ============================================================================
  
  /// Glass background with subtle opacity
  static Color glassBackground = Colors.white.withOpacity(0.05);
  
  /// Glass border with subtle opacity
  static Color glassBorder = Colors.white.withOpacity(0.15);
  
  /// Glass border stronger variant
  static Color glassBorderStrong = Colors.white.withOpacity(0.25);
  
  /// Glass background slightly stronger
  static Color glassBackgroundMedium = Colors.white.withOpacity(0.08);

  // ============================================================================
  // THEME DATA
  // ============================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        surface: backgroundColor,
        primary: primaryColor,
        secondary: accentGold,
        onSurface: onSurfaceColor,
        onPrimary: onPrimaryColor,
        onSecondary: backgroundColor,
        error: error,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: onSurfaceColor,
        ),
      ),

      // Card - minimal elevation for flat modern look
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          color: onSurfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: onSurfaceColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: onSurfaceColor,
        size: 24,
      ),
    );
  }
}

/// Text Styles for Hockey Gym V2
/// Athletic, bold typography with clear hierarchy
class AppTextStyles {
  // ============================================================================
  // TITLE STYLES
  // ============================================================================
  
  /// Extra Large Title - Hero sections
  static const TextStyle titleXL = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppTheme.onSurfaceColor,
    height: 1.2,
  );
  
  /// Large Title - Section headers
  static const TextStyle titleL = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppTheme.onSurfaceColor,
    height: 1.3,
  );
  
  /// Subtitle - Secondary headers
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppTheme.onSurfaceColor,
    height: 1.4,
  );

  // ============================================================================
  // STAT STYLES
  // ============================================================================
  
  /// Stat Value - Large numbers
  static const TextStyle statValue = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppTheme.primaryColor,
    height: 1.1,
  );
  
  /// Stat Label - Small labels under stats
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: Color(0xFF8A8A8A),
    height: 1.2,
  );

  // ============================================================================
  // BODY STYLES
  // ============================================================================
  
  /// Body Text - Main content
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppTheme.onSurfaceColor,
    height: 1.5,
  );
  
  /// Body Medium
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppTheme.onSurfaceColor,
    height: 1.5,
  );
  
  /// Small Text
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: Color(0xFF8A8A8A),
    height: 1.4,
  );

  // ============================================================================
  // LABEL STYLES
  // ============================================================================
  
  /// Extra Small Label - Uppercase tags
  static const TextStyle labelXS = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: Color(0xFF8A8A8A),
    height: 1.2,
  );
  
  /// Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onPrimaryColor,
  );
  
  /// Button Text Small
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onPrimaryColor,
  );
}

/// Spacing Constants for Hockey Gym V2
/// Consistent spacing system for layouts
class AppSpacing {
  /// Extra Small - 4px
  static const double xs = 4.0;
  
  /// Small - 8px
  static const double sm = 8.0;
  
  /// Medium - 16px
  static const double md = 16.0;
  
  /// Large - 24px
  static const double lg = 24.0;
  
  /// Extra Large - 32px
  static const double xl = 32.0;
  
  /// Extra Extra Large - 48px
  static const double xxl = 48.0;
  
  // ============================================================================
  // PADDING SHORTCUTS
  // ============================================================================
  
  /// Horizontal padding for full-width sections (20px standard)
  static const EdgeInsets horizontalPage = EdgeInsets.symmetric(horizontal: 20);
  
  /// Standard page padding
  static const EdgeInsets page = EdgeInsets.all(20);
  
  /// Card internal padding
  static const EdgeInsets card = EdgeInsets.all(16);
  
  /// Section spacing between major elements
  static const EdgeInsets section = EdgeInsets.symmetric(vertical: 24);
  
  /// Small element padding
  static const EdgeInsets small = EdgeInsets.all(8);
}

/// Glassmorphism Helper
/// Creates glass effect containers for hero sections
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? AppSpacing.card,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.glassBackground,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Gradient Divider
/// Subtle gradient line for section separation
class GradientDivider extends StatelessWidget {
  final double height;
  final EdgeInsets? margin;

  const GradientDivider({
    super.key,
    this.height = 1.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
