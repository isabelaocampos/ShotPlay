import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global visual design tokens and theme configuration for ShotPlay.
///
/// All color, typography, and component decisions live here so that
/// every screen inherits a consistent look without duplicating style code.
abstract class AppTheme {
  // Brand palette
  static const Color background = Color(0xFF16111C);
  static const Color surface = Color(0xFF1E1925);
  static const Color surfaceVariant = Color(0xFF221D29);
  static const Color primary = Color(0xFF7F0DF2);
  static const Color onPrimary = Colors.white;
  static const Color textPrimary = Color(0xFFE9DFEF);
  static const Color textSecondary = Color(0xFF978DA2);
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFFFB4AB);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: error,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF191022),
        selectedItemColor: primary,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
