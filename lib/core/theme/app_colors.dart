import 'package:flutter/material.dart';

/// HockeyForge – "Dark Ice Arena" color palette.
///
/// Defined in SPEC.md §4 Design System.
class AppColors {
  const AppColors._();

  // ---- Brand ----
  /// Primary – Ice cyan (SPEC.md).
  static const Color primary = Color(0xFF00D4FF);

  /// Electric cyan – used for active states in the rink-style bottom nav.
  static const Color electricCyan = Color(0xFF00CFFF);

  /// Soft cyan – used for active labels / icon glow.
  static const Color softCyan = Color(0xFF84EFFB);

  /// Accent – Hockey red (energy, alerts, milestones).
  static const Color accent = Color(0xFFFF4D4D);

  /// Deep red – rink line accent / Hub border.
  static const Color rinkRed = Color(0xFFC91A17);

  // ---- Backgrounds ----
  /// Deep arena black – app background.
  static const Color background = Color(0xFF0A0F1C);

  /// Slightly lifted surface for non-glass containers.
  static const Color surface = Color(0xFF111826);

  /// Even higher surface (modals, sheets).
  static const Color surfaceHigh = Color(0xFF1A2233);

  // ---- Glass (legacy) ----
  /// Fill used inside frosted glass cards.
  static const Color glassFill = Color(0x1AFFFFFF); // white @ 10%
  /// Border used on frosted glass cards (#FFFFFF15 from SPEC).
  static const Color glassBorder = Color(0x26FFFFFF); // white @ ~15%

  // ---- 2026 flat tokens ----
  /// Pure black canvas for hero areas / pull-to-refresh.
  static const Color canvasBlack = Color(0xFF05080F);

  /// Elevated card surface (slightly lighter than [surface]).
  static const Color card = Color(0xFF0F1522);

  /// Subtle hairline border, replaces glass borders for flat cards.
  static const Color hairline = Color(0x14FFFFFF); // white @ ~8%

  /// Stronger divider when needed.
  static const Color hairlineStrong = Color(0x1FFFFFFF);

  // ---- Text ----
  static const Color textPrimary = Color(0xFFF5FAFF);
  static const Color textSecondary = Color(0xFFA8B3C7);
  static const Color textMuted = Color(0xFF6B7689);

  // ---- States ----
  static const Color success = Color(0xFF22D3A6);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = accent;

  // ---- Gradients ----
  /// Signature ice-glow gradient (used in CTAs, active tab glow, charts).
  static const LinearGradient iceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF6A8CFF)],
  );

  /// Energy gradient (streaks, milestones, fire-style accents).
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D4D), Color(0xFFFF8A3D)],
  );

  /// Background vignette (subtle radial arena glow).
  static const RadialGradient arenaGradient = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: [Color(0xFF132036), Color(0xFF0A0F1C)],
  );
}
