import 'package:flutter/material.dart';

abstract final class AppColors {
  // === LIGHT MODE (Primary - Vibrant & Playful) ===
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryContainer = Color(0xFFFFF0E8);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryContainer = Color(0xFFE0F7F4);
  static const Color accent = Color(0xFFFF4081);
  static const Color background = Color(0xFFFFF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0ED);
  static const Color onBackground = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFF2D2D3A);
  static const Color onSurfaceVariant = Color(0xFF6B6B80);

  // === DARK MODE (Secondary - Premium Dark) ===
  static const Color primaryDark = Color(0xFFFF7A50);
  static const Color primaryContainerDark = Color(0xFF2A1A12);
  static const Color secondaryDark = Color(0xFF00D4B8);
  static const Color secondaryContainerDark = Color(0xFF0D2A25);
  static const Color accentDark = Color(0xFFFF4081);
  static const Color backgroundDark = Color(0xFF0D0D12);
  static const Color surfaceDark = Color(0xFF1A1A24);
  static const Color surfaceVariantDark = Color(0xFF252533);
  static const Color onBackgroundDark = Color(0xFFF5F5F5);
  static const Color onSurfaceDark = Color(0xFFE8E8EE);
  static const Color onSurfaceVariantDark = Color(0xFF9090A8);

  // === SHARED (Both Modes) ===
  static const Color favorite = Color(0xFFFF1744);
  static const Color skip = Color(0xFF78909C);
  static const Color genderMale = Color(0xFF4FC3F7);
  static const Color genderFemale = Color(0xFFFF80AB);
  static const Color genderUnisex = Color(0xFFCE93D8);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFF9A825);

  static Color genderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return genderMale;
      case 'female':
        return genderFemale;
      case 'unisex':
        return genderUnisex;
      default:
        return onSurfaceVariant;
    }
  }
}
