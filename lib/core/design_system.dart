import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumbersColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundOffWhite = Color(0xFFF8F8F8);
  static const Color textBody = Color(0xFF121212);
  static const Color textFaint = Color(0xFF666666);
  static const Color border = Color(0xFFE2E2E2);
  static const Color cardShadow = Color(0x0D000000);

  // NYT Games specific accent colors (more muted/sophisticated)
  static const Color sudoku = Color(0xFFFFA500); // Orange
  static const Color game2048 = Color(0xFF7EBDC2); // Muted Teal
  static const Color mathPuzzle = Color(0xFF4A6FA5); // Steel Blue
  static const Color sequence = Color(0xFF6C63FF); // Link Purple
  static const Color countdown = Color(0xFFD9534F); // Soft Red
  static const Color crossword = Color(0xFF5DA9E9); // Bright Blue
  static const Color linkNumbers = Color(0xFFB4A8FF); // Connections Lavender
  static const Color minesweeper = Color(0xFF5A5A5A); // Deep Grey

  // Crossword specific
  static const Color crossOperator = Color(0xFFF0F0F0);
  static const Color crossEquals = Color(0xFFF8F8F8);
  static const Color crossCorrect = Color(0xFF6AAA64); // Wordle Green
  static const Color crossIncorrect = Color(0xFFD7191C);
  static const Color selection = Color(0xFFFFD166);
}

class NumbersTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NumbersColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: NumbersColors.textBody),
        titleTextStyle: GoogleFonts.lora(
          color: NumbersColors.textBody,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: NumbersColors.sudoku,
        surface: NumbersColors.background,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.lora(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: NumbersColors.textBody,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: NumbersColors.textBody,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: NumbersColors.textBody,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: NumbersColors.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: NumbersColors.textFaint,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Sharper corners for NYT look
          side: const BorderSide(color: NumbersColors.border, width: 1),
        ),
        color: Colors.white,
      ),
    );
  }
}
