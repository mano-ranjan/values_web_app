import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color mistyBlue = Color(0xFFD2D8E0);
  static const Color beige = Color(0xFFD4B08F);
  static const Color teal = Color(0xFF016367);
  static const Color tan = Color(0xFF947062);

  // New Colors for Vibrancy & Consistency
  static const Color coral = Color(0xFFFF6F61); // For highlights/CTAs
  static const Color lightGreen = Color(0xFFB7E4C7); // For success/positive
  static const Color lavender = Color(0xFFE6E6FA); // For backgrounds/accents
  static const Color deepNavy = Color(
    0xFF223A5E,
  ); // For text/section backgrounds

  // Derived Colors
  static const Color backgroundColor = mistyBlue;
  static const Color surfaceColor = Colors.white;
  static const Color textColor = teal;
  static const Color lightTextColor = tan;
  static const Color accentColor = beige;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: teal,
        secondary: beige,
        surface: surfaceColor,
        error: Colors.red,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: textColor,
            fontSize: 56,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          displayMedium: const TextStyle(
            color: textColor,
            fontSize: 40,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          displaySmall: const TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineLarge: const TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineSmall: const TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          bodyLarge: const TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
          bodyMedium: const TextStyle(
            color: lightTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: surfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(980),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surfaceColor,
      ),
    );
  }
}
