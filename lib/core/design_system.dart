import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumbersColors {
  // Vibrant Base Palette
  static const Color background = Color(0xFFF9FAFB);
  static const Color backgroundOffWhite = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF1F2937); // Deep Slate
  static const Color textFaint = Color(0xFF6B7280); // Slate 500
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x1A000000);

  // Vibrant Component Colors (Requested Yellow & Green focus)
  static const Color yellow = Color(0xFFFFD93D);
  static const Color green = Color(0xFF6BCB77);
  static const Color blue = Color(0xFF4D96FF);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color purple = Color(0xFF916AFF);

  // Game specific (Vibrant versions)
  static const Color sudoku = yellow;
  static const Color game2048 = blue;
  static const Color mathPuzzle = coral;
  static const Color sequence = purple;
  static const Color countdown = Color(0xFFFF8E3C); // Energetic Orange
  static const Color crossword = Color(0xFF4ECDC4); // Vibrant Teal
  static const Color linkNumbers = Color(0xFFFF6AC1); // Punchy Pink
  static const Color minesweeper = Color(0xFF393E46); // Modern Dark Slate

  // Status
  static const Color crossCorrect = green;
  static const Color crossIncorrect = coral;
  static const Color selection = yellow;
}

class NumbersTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NumbersColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: NumbersColors.background,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: NumbersColors.textBody),
        titleTextStyle: GoogleFonts.outfit(
          color: NumbersColors.textBody,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: NumbersColors.purple,
        surface: NumbersColors.backgroundOffWhite,
        primary: NumbersColors.purple,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: NumbersColors.textBody,
          letterSpacing: -1.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: NumbersColors.textBody,
          letterSpacing: -1,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: NumbersColors.textBody,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NumbersColors.textBody,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: NumbersColors.textFaint,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Modern rounded corners
          side: const BorderSide(color: NumbersColors.border, width: 1.5),
        ),
        color: NumbersColors.backgroundOffWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}
