import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF4894FE); // biru
  static const Color secondary = Color(0xFFB3FEB5); // hijau
  static const Color background = Color(0xFFF5F5F5); // abu-abu muda
  static const Color textPrimary = Color(0xFF333333); // teks utama
  static const Color textSecondary = Color(0xFF777777); // teks sekunder
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodyLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        titleLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
