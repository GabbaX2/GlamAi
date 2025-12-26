import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlack = Color(0xFF0D0D0D);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF242424);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGray = Color(0xFF8A8A8A);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  
  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: goldAccent.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  
  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: champagne,
        surface: cardBackground,
        error: errorRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: pureWhite,
            letterSpacing: -1,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: pureWhite,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: pureWhite,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: pureWhite,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: pureWhite,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: pureWhite,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: pureWhite,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: softGray,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: goldAccent,
            letterSpacing: 1.2,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: pureWhite,
        ),
        iconTheme: const IconThemeData(color: pureWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: primaryBlack,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          side: const BorderSide(color: goldAccent, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: goldAccent, width: 2),
        ),
        hintStyle: const TextStyle(color: softGray),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryBlack,
        selectedItemColor: goldAccent,
        unselectedItemColor: softGray,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Glass effect decoration
class GlassDecoration extends BoxDecoration {
  GlassDecoration({
    double opacity = 0.1,
    double borderRadius = AppTheme.radiusMedium,
  }) : super(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        );
}
