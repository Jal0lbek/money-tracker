import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primaryGreen = Color(0xFF00D4AA);
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF7C3AED);

  // Account colors
  static const Color naqdColor = Color(0xFF00D4AA);
  static const Color kartaColor = Color(0xFF0066FF);
  static const Color bankColor = Color(0xFF7C3AED);
  static const Color valyutaColor = Color(0xFFFF6B35);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E1A),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: primaryBlue,
      surface: Color(0xFF131929),
      error: Color(0xFFFF4757),
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0A0E1A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF131929),
      selectedItemColor: primaryGreen,
      unselectedItemColor: Color(0xFF4A5568),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF131929),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A2332),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFF4A5568)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B894),
      secondary: primaryBlue,
      surface: Colors.white,
      error: Color(0xFFFF4757),
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: const Color(0xFF1A2332),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1A2332)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF00B894),
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00B894), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
    ),
  );
}
