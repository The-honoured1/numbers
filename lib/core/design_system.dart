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

extension ThemeColorsExt on BuildContext {
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get border => Theme.of(this).colorScheme.onSurface; // Border always matches text color
  Color get shadow => Theme.of(this).colorScheme.onSurface; // Shadow matches text/border color
  Color get textFaint => Theme.of(this).brightness == Brightness.dark ? const Color(0xFFAAAAAA) : const Color(0xFF555555);
}

class NumbersTheme {
  
  static final TextTheme _baseTextTheme = GoogleFonts.outfitTextTheme();
  
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final Color textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final Color borderColor = textColor;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.unifrakturMaguntia(
          color: textColor,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: NumbersColors.blue,
        surface: bgColor,
        onSurface: textColor,
        primary: NumbersColors.blue,
      ),
      textTheme: _baseTextTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: textColor,
          height: 1.1,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: textColor,
          height: 1.1,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 2.5),
        ),
        color: bgColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: NumbersColors.yellow,
          foregroundColor: const Color(0xFF000000), // Keep button text black for visibility on vibrant colors
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 2.5),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}

