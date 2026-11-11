import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dana / GoPay Modern Fintech Color Palette
  static const Color danaBlue = Color(0xFF118EEA);
  static const Color danaBlueDark = Color(0xFF0C69B0);
  static const Color danaBlueLight = Color(0xFFE8F4FD);
  static const Color primaryNavy = Color(0xFF0D253C);

  static const Color starGold = Color(0xFFFFB800);
  static const Color starGoldLight = Color(0xFFFFF7E6);

  static const Color successGreen = Color(0xFF00B14F);
  static const Color successGreenLight = Color(0xFFE6F7ED);

  static const Color warningOrange = Color(0xFFFF7A00);
  static const Color warningOrangeLight = Color(0xFFFFF2E8);

  static const Color errorRed = Color(0xFFFF4D4F);
  static const Color errorRedLight = Color(0xFFFFECEB);

  static const Color background = Color(0xFFF7F9FC);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Theme Palette (Persis seperti Web Tailwind Slate)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkCardBg = Color(0xFF1E293B); // Slate 800
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkTextMain = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: danaBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: danaBlue,
        primary: danaBlue,
        secondary: starGold,
        surface: cardBg,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textMain,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textMain,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textMain,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textMain,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: danaBlue,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: danaBlue,
      colorScheme: const ColorScheme.dark(
        primary: danaBlue,
        secondary: starGold,
        surface: darkCardBg,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: darkTextMain,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: darkTextMain,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: darkTextMain,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: darkTextMain,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
    );
  }

  // Soft fintech shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF108EE9).withAlpha(15),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: const Color(0xFF118EEA).withAlpha(60),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
