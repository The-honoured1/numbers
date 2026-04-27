import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumbersColors {
  // NYT Games Neo-Brutalist Palette
  static const Color background = Color(0xFFF9FAFB);
  static const Color backgroundOffWhite = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF000000); // Pitch Black
  static const Color textFaint = Color(0xFF555555); // Dark Gray
  static const Color border = Color(0xFF000000); // Hard Black Borders
  static const Color cardShadow = Color(0xFF000000); // Solid Black Shadows

  // Vibrant Component Colors (From Image)
  static const Color yellow = Color(0xFFF5D64C); // Mustard Yellow
  static const Color green = Color(0xFF8DCA64); // Grass Green
  static const Color blue = Color(0xFF8BB5F3); // Cornflower Blue
  static const Color orange = Color(0xFFF6A13D); // Vibrant Orange
  static const Color purple = Color(0xFFB1A9FF); // Pastel Purple
  static const Color coral = Color(0xFFFF6B6B); // Kept coral, tweaked

  // Game specific (Mapped to vibrant versions)
  static const Color sudoku = yellow;
  static const Color game2048 = blue;
  static const Color mathPuzzle = coral;
  static const Color sequence = purple;
  static const Color countdown = orange; 
  static const Color crossword = green; 
  static const Color linkNumbers = Color(0xFFFF6AC1); 
  static const Color minesweeper = Color(0xFFC0C0C0); // Classic gray for minesweeper, or maybe deep slate

  // Status
  static const Color crossCorrect = green;
  static const Color crossIncorrect = coral;
  static const Color selection = yellow;
}

class NumbersTheme {
  
  static final TextTheme _baseTextTheme = GoogleFonts.outfitTextTheme();
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NumbersColors.backgroundOffWhite, // NYT uses stark white backgrounds
      appBarTheme: AppBarTheme(
        backgroundColor: NumbersColors.backgroundOffWhite,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: NumbersColors.textBody),
        titleTextStyle: GoogleFonts.unifrakturMaguntia( // The gothic title look
          color: NumbersColors.textBody,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: NumbersColors.blue,
        surface: NumbersColors.backgroundOffWhite,
        primary: NumbersColors.blue,
      ),
      textTheme: _baseTextTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay( // Classic Serif for huge headings
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: NumbersColors.textBody,
          height: 1.1,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: NumbersColors.textBody,
          height: 1.1,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: NumbersColors.textBody,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: NumbersColors.textBody,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: NumbersColors.textBody,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Slightly sharper corners
          side: const BorderSide(color: NumbersColors.border, width: 2.5), // Thick black border
        ),
        color: NumbersColors.backgroundOffWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: NumbersColors.border, width: 2.5),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}

