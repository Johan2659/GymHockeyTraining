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
  
  /// Secondary text color - better contrast
  static const Color secondaryTextColor = Color(0xFFB0B0B0);
  
  /// Tertiary text color - subtle text
  static const Color tertiaryTextColor = Color(0xFF7A7A7A);
  
  /// Secondary accent (keeping backward compatibility)
  static const Color accentColor = primaryColor;
  
  // ============================================================================
  // SEMANTIC UI COLORS
  // ============================================================================
  
  /// Subtle border color for UI elements
  static Color borderColor = const Color(0xFF2A2A2A);
  
  /// Divider color for separating content
  static Color dividerColor = const Color(0xFF1F1F1F);
  
  /// Disabled state color
  static Color disabledColor = const Color(0xFF4A4A4A);
  
  /// Overlay/barrier background
  static Color overlayBackground = Colors.black.withOpacity(0.5);
  
  /// Shadow color for cards and elevated elements
  static Color shadowColor = Colors.black.withOpacity(0.3);
  
  /// Shimmer/loading background
  static Color shimmerBase = const Color(0xFF1A1A1A);
  static Color shimmerHighlight = const Color(0xFF2A2A2A);
  
  // Greys - for various UI states
  static const Color grey900 = Color(0xFF0F0F0F);
  static const Color grey850 = Color(0xFF1A1A1A);
  static const Color grey800 = Color(0xFF2A2A2A);
  static const Color grey700 = Color(0xFF3A3A3A);
  static const Color grey600 = Color(0xFF5A5A5A);
  static const Color grey500 = Color(0xFF7A7A7A);
  static const Color grey400 = Color(0xFF9A9A9A);
  static const Color grey300 = Color(0xFFB0B0B0);
  
  // Semantic colors for various categories
  static const Color programs = Color(0xFF00B4FF);
  static const Color extras = Color(0xFF9C27B0);
  static const Color warmup = Color(0xFFFF9500);
  static const Color cooldown = Color(0xFF00BCD4);
  
  // Status colors  
  static const Color bonus = Color(0xFFFFB84D);
  static const Color completed = Color(0xFF4CAF50);
  static const Color inProgress = Color(0xFFFF9500);
  static const Color notStarted = grey600;
  
  // Timer colors
  static const Color timerWork = Color(0xFFFF6B35);
  static const Color timerRest = Color(0xFF00B4FF);
  
  // ============================================================================
  // EXTENDED SEMANTIC COLORS (2025 Enhancement)
  // ============================================================================
  
  /// Info blue - for informational elements and links
  static const Color info = Color(0xFF42A5F5);
  
  /// Warning orange shades - for emphasis and warnings
  static const Color warningLight = Color(0xFFFFA726);
  static const Color warningMedium = Color(0xFFFFB74D);
  static const Color warningLighter = Color(0xFFFFCC80);
  
  /// Chart colors - consistent palette for data visualization
  static const Color chartRed = Color(0xFFFF5252);
  static const Color chartBlue = Color(0xFF448AFF);
  static const Color chartIndigo = Color(0xFF536DFE);
  static const Color chartTeal = Color(0xFF1DE9B6);
  static const Color chartPink = Color(0xFFFF4081);
  static const Color chartAmber = Color(0xFFFFD740);
  static const Color chartLightGreen = Color(0xFF69F0AE);
  static const Color chartDeepOrange = Color(0xFFFF6E40);
  static const Color chartCyan = Color(0xFF18FFFF);
  
  /// Standard delete/danger red
  static const Color danger = Color(0xFFFF3B30);
  
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
  // LIGHT THEME COLORS
  // ============================================================================
  
  /// Light background - clean white with subtle warmth
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  
  /// Light surface color for cards and containers
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  
  /// Darker primary for better contrast on light background
  static const Color lightPrimaryColor = Color(0xFF0096D6);
  
  /// Rich amber for light mode accents
  static const Color lightAccentGold = Color(0xFFFF9500);
  
  /// Text color for light backgrounds
  static const Color lightOnSurfaceColor = Color(0xFF1A1A1A);
  
  /// Text on primary color (light mode)
  static const Color lightOnPrimaryColor = Color(0xFFFFFFFF);
  
  /// Secondary text for light mode
  static const Color lightSecondaryTextColor = Color(0xFF5A5A5A);
  
  /// Tertiary text for light mode
  static const Color lightTertiaryTextColor = Color(0xFF8A8A8A);

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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        surface: lightBackgroundColor,
        primary: lightPrimaryColor,
        secondary: lightAccentGold,
        onSurface: lightOnSurfaceColor,
        onPrimary: lightOnPrimaryColor,
        onSecondary: lightOnSurfaceColor,
        error: error,
      ),

      // Scaffold
      scaffoldBackgroundColor: lightBackgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurfaceColor,
        foregroundColor: lightOnSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: lightOnSurfaceColor,
        ),
      ),

      // Card - subtle shadow for depth in light mode
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightOnSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: lightOnSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          color: lightOnSurfaceColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          color: lightOnSurfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: lightOnSurfaceColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: lightOnPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: lightPrimaryColor.withOpacity(0.3),
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
          foregroundColor: lightPrimaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: lightOnSurfaceColor,
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
  
  /// Stat Label - Small labels under stats (2025 Best Practice: 12sp minimum)
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: Color(0xFF8A8A8A),
    height: 1.2,
  );

  // ============================================================================
  // BODY STYLES - 2025 UX Standards
  // ============================================================================
  
  /// Body Text - Main content (Premium readability)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppTheme.onSurfaceColor,
    height: 1.5,
  );
  
  /// Body Medium (Optimal for mobile reading)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppTheme.onSurfaceColor,
    height: 1.5,
  );
  
  /// Small Text (Minimum comfortable reading size)
  static const TextStyle small = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: Color(0xFF9A9A9A),
    height: 1.4,
  );

  // ============================================================================
  // LABEL STYLES - 2025 Accessibility Standards
  // ============================================================================
  
  /// Label Small - For descriptions and secondary info (12sp minimum)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF9A9A9A),
    height: 1.3,
  );
  
  /// Label Medium - For category names and tags (Enhanced readability)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: Color(0xFF9A9A9A),
    height: 1.2,
  );
  
  /// Label Micro - Compact labels, uppercase recommended (12sp minimum for 2025)
  static const TextStyle labelMicro = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.4,
    color: Color(0xFF9A9A9A),
    height: 1.2,
  );
  
  /// Button Text (Premium tap target)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onPrimaryColor,
  );
  
  /// Button Text Small (Minimum for comfort)
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onPrimaryColor,
  );
  
  /// Caption - Smallest readable text for metadata (12sp for 2025)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF9A9A9A),
    height: 1.3,
  );
  
  // ============================================================================
  // SPECIALIZED STYLES - Context-Specific (2025 Best Practice)
  // ============================================================================
  
  /// Display Large - Extra large numbers and heroes (stats, countdowns)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.1,
  );
  
  /// Display Medium - Large numbers (30-32sp)
  static const TextStyle displayMedium = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.1,
  );
  
  /// Headline Small - Smaller section headers (20sp)
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.3,
  );
  
  /// Body Large+ - Emphasized body text (17sp)
  static const TextStyle bodyLargePlus = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppTheme.onSurfaceColor,
    height: 1.5,
  );
  
  /// Subtitle Large - Larger secondary headers (18sp)
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.4,
  );
  
  /// Button Large - Prominent CTA buttons (18sp)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
    color: AppTheme.onPrimaryColor,
  );
  
  /// Headline Medium - Mid-sized headers (22sp)
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.3,
  );
  
  /// Label Medium Small - Between label and small (13sp)
  static const TextStyle labelMediumSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppTheme.secondaryTextColor,
    height: 1.4,
  );
  
  /// Display XL - Extra-large hero numbers (32sp)
  static const TextStyle displayXL = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppTheme.onSurfaceColor,
    height: 1.1,
  );
}

/// =============================================================================
/// TYPOGRAPHY USAGE GUIDE (2025 Best Practices)
/// =============================================================================
/// 
/// HIERARCHY (Use these, don't override fontSize):
/// 
/// Display:
///   displayLarge (36sp)  - Hero numbers, main stats, timers
///   displayXL (32sp)     - Extra-large hero displays
///   displayMedium (30sp) - Secondary large numbers
///   statValue (36sp)     - Athletic stat displays
/// 
/// Titles:
///   titleXL (32sp)       - Page titles, hero sections
///   titleL (24sp)        - Main section headers
///   headlineMedium (22sp)- Mid-sized headers
///   headlineSmall (20sp) - Sub-section headers
///   subtitle (18sp)      - Secondary headers
///   subtitleLarge (18sp) - Emphasized secondary headers
/// 
/// Body:
///   body (16sp)          - Main readable content
///   bodyLargePlus (17sp) - Emphasized content
///   bodyMedium (15sp)    - Standard secondary content
///   small (13sp)         - Supporting information
/// 
/// Labels & Captions:
///   labelMedium (13sp)      - Category names, tags (bold)
///   labelMediumSmall (13sp) - Between label and small
///   labelSmall (12sp)       - Descriptions, metadata
///   labelMicro (12sp)       - Compact uppercase labels
///   caption (12sp)          - Timestamps, footnotes
///   statLabel (12sp)        - Labels under statistics
/// 
/// Buttons:
///   buttonLarge (18sp)   - Primary CTAs
///   button (16sp)        - Standard buttons
///   buttonSmall (14sp)   - Compact buttons
/// 
/// ✅ DO:
///   - Use theme styles directly: AppTextStyles.titleL
///   - Only modify color/weight: .copyWith(color: AppTheme.primaryColor)
///   - Add new semantic styles when needed
/// 
/// ❌ DON'T:
///   - Override fontSize: .copyWith(fontSize: 22) 
///   - Use raw TextStyle() with hardcoded sizes
///   - Mix theme styles with manual sizing
/// 
/// BENEFITS:
///   ✨ Change theme.dart → entire app updates
///   ✨ Consistent visual hierarchy
///   ✨ Easy to add responsive scaling
///   ✨ Accessibility-friendly (system font scaling)
///   ✨ Maintainable and professional
/// =============================================================================

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
  // ADDITIONAL SPACING VALUES (2025 Enhancement)
  // ============================================================================
  
  /// Tiny - 6px (for compact spacing)
  static const double tiny = 6.0;
  
  /// Medium-Small - 12px (between sm and md)
  static const double ms = 12.0;
  
  /// Medium-Large - 20px (between md and lg)
  static const double ml = 20.0;
  
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
