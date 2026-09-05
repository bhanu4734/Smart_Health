import 'package:flutter/material.dart';

class AppColors {
  // Main backgrounds
  static const Color background = Color(0xFFF6F7FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color subCardBackground = Color(0xFFF8FAFC);
  
  // Outer frame / accents
  static const Color purpleAccent = Color(0xFF5B5CE2);
  static const Color purpleLight = Color(0xFFEEF0FD);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderCard = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFEEF2F6);

  // Status - Safe / Green
  static const Color greenBadgeBg = Color(0xFFECFDF5);
  static const Color greenBadgeBorder = Color(0xFFA7F3D0);
  static const Color greenText = Color(0xFF059669);
  static const Color greenDot = Color(0xFF10B981);

  // Status - Triage / Warning / Red
  static const Color redBadgeBg = Color(0xFFFEF2F2);
  static const Color redBadgeBorder = Color(0xFFFECACA);
  static const Color redText = Color(0xFFDC2626);

  // Category Tag Colors
  static const Color tagAntibioticBg = Color(0xFFEFF6FF);
  static const Color tagAntibioticBorder = Color(0xFFBFDBFE);
  static const Color tagAntibioticText = Color(0xFF2563EB);

  static const Color tagRehydrationBg = Color(0xFFFFFBEB);
  static const Color tagRehydrationBorder = Color(0xFFFDE68A);
  static const Color tagRehydrationText = Color(0xFFD97706);

  static const Color tagAnalgesicBg = Color(0xFFF5F3FF);
  static const Color tagAnalgesicBorder = Color(0xFFDDD6FE);
  static const Color tagAnalgesicText = Color(0xFF7C3AED);

  static const Color tagEmergencyBg = Color(0xFFFEF2F2);
  static const Color tagEmergencyBorder = Color(0xFFFECACA);
  static const Color tagEmergencyText = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purpleAccent,
        brightness: Brightness.light,
        surface: AppColors.cardBackground,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
