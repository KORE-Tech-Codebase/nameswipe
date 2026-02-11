import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Nunito';

  // Font Sizes
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeDisplay = 32.0;
  static const double fontSizeCardName = 40.0;

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: FontWeight.w800,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: fontSizeHeading,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: fontSizeXxl,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeXl,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSm,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: fontSizeMd,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: fontSizeXs,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );

  static const TextStyle cardName = TextStyle(
    fontSize: fontSizeCardName,
    fontWeight: FontWeight.w800,
    fontFamily: fontFamily,
    height: 1.1,
    color: Colors.white,
  );

  static const TextStyle cardMeaning = TextStyle(
    fontSize: fontSizeLg,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    height: 1.4,
    color: Colors.white70,
  );
}
