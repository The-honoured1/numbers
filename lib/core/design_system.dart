import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumbersColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF121212);
  static const Color textFaint = Color(0xFF757575);
  static const Color cardShadow = Color(0x1A000000);

  // Game specific accent colors
  static const Color sudoku = Color(0xFF5DA9E9);
  static const Color game2048 = Color(0xFFF4A261);
  static const Color mathPuzzle = Color(0xFF2A9D8F);
  static const Color sequence = Color(0xFF9B5DE5);
  static const Color countdown = Color(0xFFE76F51);
  static const Color crossword = Color(0xFFFFD166);

  // Crossword specific
  static const Color crossOperator = Color(0xFFE0E0E0);
  static const Color crossEquals = Color(0xFFFFEB3B);
  static const Color crossCorrect = Color(0xFFC8E6C9);
  static const Color crossIncorrect = Color(0xFFFFCDD2);
}

class NumbersTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NumbersColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: NumbersColors.sudoku,
        surface: NumbersColors.background,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.lora(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: NumbersColors.textBody,
          letterSpacing: -1.5,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: NumbersColors.textBody,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: NumbersColors.textBody,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: NumbersColors.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: NumbersColors.textFaint,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        color: Colors.white,
      ),
    );
  }
}
