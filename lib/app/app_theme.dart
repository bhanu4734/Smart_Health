import 'package:flutter/material.dart';

class AppColors {
  // Core Backgrounds
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  // Purple Accent (Signature border & active brand)
  static const Color purpleAccent = Color(0xFF5B5CE2);
  static const Color purpleLight = Color(0xFFEEF0FD);
  static const Color purpleHover = Color(0xFF4A4BC8);

  // Blue Primary
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);
  static const Color primaryBlueBorder = Color(0xFFBFDBFE);

  // Status - Green (Safe / Available)
  static const Color greenText = Color(0xFF059669);
  static const Color greenDot = Color(0xFF10B981);
  static const Color greenBg = Color(0xFFECFDF5);
  static const Color greenBorder = Color(0xFFA7F3D0);

  // Status - Amber (Warning / Moderate)
  static const Color amberText = Color(0xFFD97706);
  static const Color amberDot = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberBorder = Color(0xFFFDE68A);

  // Status - Red (Critical / Stockout / Alert)
  static const Color redText = Color(0xFFDC2626);
  static const Color redDot = Color(0xFFEF4444);
  static const Color redBg = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);
  static const Color redDark = Color(0xFFB91C1C);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderCard = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFEEF2F6);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppRadius {
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double pill = 999.0;
}

class AppTextStyles {
  static const TextStyle brandTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.purpleAccent,
    letterSpacing: -0.3,
  );

  static const TextStyle pageHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle contextNode = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  static const TextStyle subtext = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bigStat = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
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
        surface: AppColors.surface,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
