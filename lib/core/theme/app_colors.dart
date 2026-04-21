import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary (Forest Green) ---
  static const Color primary = Color(0xFF006C4F);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFF00D09C);
  static const Color onPrimaryContainer = Color(0xFF00533C);
  static const Color primaryFixed = Color(0xFF59FDC5);
  static const Color primaryFixedDim = Color(0xFF2FE0AA);
  static const Color onPrimaryFixed = Color(0xFF002116);

  // --- Secondary ---
  static const Color secondary = Color(0xFF5F5E5E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE5E2E1);
  static const Color onSecondaryContainer = Color(0xFF656464);

  // --- Tertiary (Editorial Red — loss/sell) ---
  static const Color tertiary = Color(0xFFB02C31);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFFF9D98);
  static const Color onTertiaryContainer = Color(0xFF91131E);
  static const Color tertiaryFixed = Color(0xFFFFDAD7);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AF);
  static const Color onTertiaryFixed = Color(0xFF410005);

  // --- Surface hierarchy ---
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceDim = Color(0xFFD9DADB);
  static const Color surfaceBright = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);

  // --- On-surface ---
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF3C4A43);
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F2);

  // --- Outline ---
  static const Color outline = Color(0xFF6B7B72);
  static const Color outlineVariant = Color(0xFFBACEC1);

  // --- Error ---
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // --- Semantic shortcuts ---
  static const Color gain = primary;
  static const Color loss = tertiary;
  static const Color gainBackground = Color(0xFFDCF5ED);
  static const Color lossBackground = Color(0xFFFFECEB);

  // --- Gradient helpers ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient portfolioGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF004D38), Color(0xFF006C4F)],
  );
}






