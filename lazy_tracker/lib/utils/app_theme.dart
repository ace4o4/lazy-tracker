import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color bgColor = Color(0xFF0B0C10);
  static const Color surfaceColor = Color(0xFF1F212E);
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFF00CEC9);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8B8C9C);
  static const Color streakColor = Color(0xFFFF9F43);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
            bodyLarge: GoogleFonts.outfit(color: textMain),
            bodyMedium: GoogleFonts.outfit(color: textMuted),
          ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withAlpha(25),
          ), // 10% opacity -> 25 alpha
        ),
      ),
    );
  }
}
