import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'konstanta.dart';

/// Tema aplikasi MagangKu
class TemaAplikasi {
  TemaAplikasi._();

  /// Tema terang (default)
  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: WarnaAplikasi.background,
        appBarTheme: _appBarTheme,
        cardTheme: _cardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        bottomNavigationBarTheme: _bottomNavTheme,
        floatingActionButtonTheme: _fabTheme,
        textTheme: _textTheme,
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E7EB),
          thickness: 1,
        ),
      );

  // Color Scheme
  static ColorScheme get _colorScheme => const ColorScheme.light(
        primary: WarnaAplikasi.primary,
        onPrimary: WarnaAplikasi.textOnPrimary,
        secondary: WarnaAplikasi.primaryLight,
        onSecondary: WarnaAplikasi.textOnPrimary,
        surface: WarnaAplikasi.surface,
        onSurface: WarnaAplikasi.textPrimary,
        error: WarnaAplikasi.error,
        onError: WarnaAplikasi.textOnPrimary,
      );

  // AppBar Theme
  static AppBarTheme get _appBarTheme => AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: WarnaAplikasi.surface,
        foregroundColor: WarnaAplikasi.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: UkuranAplikasi.fontBesar,
          fontWeight: FontWeight.w600,
          color: WarnaAplikasi.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: WarnaAplikasi.textPrimary,
        ),
      );

  // Card Theme
  static CardThemeData get _cardTheme => CardThemeData(
        elevation: UkuranAplikasi.elevasiKecil,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
        ),
        color: WarnaAplikasi.cardBackground,
        margin: const EdgeInsets.symmetric(
          horizontal: UkuranAplikasi.marginKecil,
          vertical: UkuranAplikasi.marginKecil / 2,
        ),
      );

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: WarnaAplikasi.primary,
          foregroundColor: WarnaAplikasi.textOnPrimary,
          minimumSize: const Size(double.infinity, UkuranAplikasi.tinggiButton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UkuranAplikasi.radiusButton),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: UkuranAplikasi.fontNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WarnaAplikasi.primary,
          minimumSize: const Size(double.infinity, UkuranAplikasi.tinggiButton),
          side: const BorderSide(color: WarnaAplikasi.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UkuranAplikasi.radiusButton),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: UkuranAplikasi.fontNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: WarnaAplikasi.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: UkuranAplikasi.fontSedang,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: WarnaAplikasi.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UkuranAplikasi.paddingSedang,
          vertical: UkuranAplikasi.paddingSedang,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
          borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
          borderSide: const BorderSide(color: WarnaAplikasi.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
          borderSide: const BorderSide(color: WarnaAplikasi.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: WarnaAplikasi.textSecondary,
          fontSize: UkuranAplikasi.fontSedang,
        ),
        hintStyle: GoogleFonts.poppins(
          color: WarnaAplikasi.textLight,
          fontSize: UkuranAplikasi.fontSedang,
        ),
        errorStyle: GoogleFonts.poppins(
          color: WarnaAplikasi.error,
          fontSize: UkuranAplikasi.fontKecil,
        ),
      );

  // Bottom Navigation Theme
  static BottomNavigationBarThemeData get _bottomNavTheme =>
      BottomNavigationBarThemeData(
        elevation: UkuranAplikasi.elevasiBesar,
        backgroundColor: WarnaAplikasi.surface,
        selectedItemColor: WarnaAplikasi.primary,
        unselectedItemColor: WarnaAplikasi.textLight,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: UkuranAplikasi.fontKecil,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: UkuranAplikasi.fontKecil,
          fontWeight: FontWeight.w400,
        ),
      );

  // FAB Theme
  static FloatingActionButtonThemeData get _fabTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: WarnaAplikasi.primary,
        foregroundColor: WarnaAplikasi.textOnPrimary,
        elevation: UkuranAplikasi.elevasiSedang,
      );

  // Text Theme
  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: WarnaAplikasi.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: WarnaAplikasi.textPrimary,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: WarnaAplikasi.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: WarnaAplikasi.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: WarnaAplikasi.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: WarnaAplikasi.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: WarnaAplikasi.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: WarnaAplikasi.textSecondary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: WarnaAplikasi.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: WarnaAplikasi.textPrimary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: WarnaAplikasi.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: WarnaAplikasi.textPrimary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: WarnaAplikasi.textLight,
        ),
      );
}
