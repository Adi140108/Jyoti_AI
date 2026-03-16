import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JyotiTheme {
  // ── Core Colors ──
  static const Color background = Color(0xFF0B0B14);
  static const Color surface = Color(0xFF12121E);
  static const Color surfaceVariant = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF151525);
  static const Color border = Color(0xFF2A2A3E);
  static const Color borderSubtle = Color(0xFF1E1E30);

  // ── Gold / Amber Accent (Jyoti = Light) ──
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldGlow = Color(0x33F59E0B);
  static const Color goldSurface = Color(0x0DF59E0B);

  // ── Spiritual Purple ──
  static const Color cosmic = Color(0xFF7C3AED);
  static const Color cosmicLight = Color(0xFFA78BFA);
  static const Color cosmicDark = Color(0xFF5B21B6);
  static const Color cosmicGlow = Color(0x337C3AED);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1B5);
  static const Color textMuted = Color(0xFF71718A);
  static const Color textSubtle = Color(0xFF52526B);

  // ── Status ──
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Rashi Colors ──
  static const Color aries = Color(0xFFEF4444);
  static const Color taurus = Color(0xFF22C55E);
  static const Color gemini = Color(0xFFFBBF24);
  static const Color cancer = Color(0xFFC0C0C0);
  static const Color leo = Color(0xFFFF8C00);
  static const Color virgo = Color(0xFF10B981);
  static const Color libra = Color(0xFF60A5FA);
  static const Color scorpio = Color(0xFFDC2626);
  static const Color sagittarius = Color(0xFF8B5CF6);
  static const Color capricorn = Color(0xFF6B7280);
  static const Color aquarius = Color(0xFF06B6D4);
  static const Color pisces = Color(0xFF818CF8);

  // ── Tier Colors ──
  static const Color tierMoon = Color(0xFFC0C0C0);
  static const Color tierStar = Color(0xFFFBBF24);
  static const Color tierSun = Color(0xFFFF8C00);
  static const Color tierNakshatra = Color(0xFFA78BFA);

  // ── Gradients ──
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [cosmicDark, cosmic, cosmicLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF0B0B14), Color(0xFF1A1A3E), Color(0xFF0B0B14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF12121E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Spacing ──
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  // ── Radius ──
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radiusFull = 100;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: cosmic,
        surface: surface,
        error: error,
        onPrimary: Color(0xFF1A1A2E),
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: textSecondary, height: 1.6),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
            height: 1.5,
          ),
          bodySmall: TextStyle(fontSize: 12, color: textMuted),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textMuted,
            letterSpacing: 1.0,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        hintStyle: const TextStyle(color: textSubtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: gold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }

  // ── Light Theme Colors ──
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F2EE);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E3DB);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A4A5E);
  static const Color lightTextMuted = Color(0xFF8A8A9E);
  static const Color lightTextSubtle = Color(0xFFB0B0C0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: goldDark,
        secondary: cosmic,
        surface: lightSurface,
        error: error,
        onPrimary: Color(0xFFFFFBF5),
        onSecondary: lightTextPrimary,
        onSurface: lightTextPrimary,
        onError: Color(0xFFFFFBF5),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: lightTextPrimary,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: lightTextPrimary,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: lightTextPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: lightTextPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: lightTextPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: lightTextPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: lightTextSecondary, height: 1.6),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: lightTextSecondary,
            height: 1.5,
          ),
          bodySmall: TextStyle(fontSize: 12, color: lightTextMuted),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: lightTextPrimary,
            letterSpacing: 0.5,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: lightTextMuted,
            letterSpacing: 1.0,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: goldDark, width: 2),
        ),
        hintStyle: const TextStyle(color: lightTextSubtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldDark,
          foregroundColor: Color(0xFFFFFBF5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: goldDark,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
    );
  }
}
