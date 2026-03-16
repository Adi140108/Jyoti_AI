import 'package:flutter/material.dart';
import 'package:jyoti_ai/theme/app_theme.dart';

/// Theme-aware color resolver.
/// Use `JyotiColors.of(context).background` etc. to get the right color
/// for the current light/dark mode.
class JyotiColors {
  final bool isDark;

  const JyotiColors._({required this.isDark});

  factory JyotiColors.of(BuildContext context) {
    return JyotiColors._(
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  // ── Backgrounds & Surfaces ──
  Color get background =>
      isDark ? JyotiTheme.background : JyotiTheme.lightBackground;
  Color get surface =>
      isDark ? JyotiTheme.surface : JyotiTheme.lightSurface;
  Color get surfaceVariant =>
      isDark ? JyotiTheme.surfaceVariant : JyotiTheme.lightSurfaceVariant;
  Color get cardBg =>
      isDark ? JyotiTheme.cardBg : JyotiTheme.lightCardBg;
  Color get border =>
      isDark ? JyotiTheme.border : JyotiTheme.lightBorder;
  Color get borderSubtle =>
      isDark ? JyotiTheme.borderSubtle : JyotiTheme.lightBorder;

  // ── Text ──
  Color get textPrimary =>
      isDark ? JyotiTheme.textPrimary : JyotiTheme.lightTextPrimary;
  Color get textSecondary =>
      isDark ? JyotiTheme.textSecondary : JyotiTheme.lightTextSecondary;
  Color get textMuted =>
      isDark ? JyotiTheme.textMuted : JyotiTheme.lightTextMuted;
  Color get textSubtle =>
      isDark ? JyotiTheme.textSubtle : JyotiTheme.lightTextSubtle;

  // ── Accents (same in both modes) ──
  Color get gold => JyotiTheme.gold;
  Color get goldLight => JyotiTheme.goldLight;
  Color get goldDark => JyotiTheme.goldDark;
  Color get goldGlow => JyotiTheme.goldGlow;
  Color get goldSurface => JyotiTheme.goldSurface;
  Color get cosmic => JyotiTheme.cosmic;
  Color get cosmicLight => JyotiTheme.cosmicLight;
  Color get cosmicDark => JyotiTheme.cosmicDark;
  Color get cosmicGlow => JyotiTheme.cosmicGlow;

  // ── Gradients ──
  LinearGradient get skyGradient => isDark
      ? JyotiTheme.skyGradient
      : const LinearGradient(
          colors: [Color(0xFFFAF9F6), Color(0xFFF0EDE5), Color(0xFFFAF9F6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  LinearGradient get cardGradient => isDark
      ? JyotiTheme.cardGradient
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F7F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
}
