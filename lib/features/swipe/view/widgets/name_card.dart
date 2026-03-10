import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/typography.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/models/name_model.dart';

class NameCard extends StatelessWidget {
  final NameModel name;
  final LinearGradient gradient;

  const NameCard({
    super.key,
    required this.name,
    required this.gradient,
  });

  String get _genderSymbol {
    switch (name.gender.toLowerCase()) {
      case 'male':
        return '\u2642';
      case 'female':
        return '\u2640';
      default:
        return '\u26A5';
    }
  }

  String get _genderLabel {
    switch (name.gender.toLowerCase()) {
      case 'male':
        return 'Boy';
      case 'female':
        return 'Girl';
      default:
        return 'Unisex';
    }
  }

  String get _babySvgAsset {
    switch (name.gender.toLowerCase()) {
      case 'male':
        return 'assets/svg/baby_boy.svg';
      case 'female':
        return 'assets/svg/baby_girl.svg';
      default:
        return 'assets/svg/baby_unisex.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderColor = AppColors.genderColor(name.gender);
    final hasOrigin = name.origin.isNotEmpty;
    final hasMeaning = name.meaning.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Baby silhouette SVG background
            Positioned(
              right: -10,
              bottom: 40,
              child: SvgPicture.asset(
                _babySvgAsset,
                width: 180,
                height: 180,
              ),
            ),

            // Static radial glow behind name
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 0.9,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Top gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Category chip — top left
            Positioned(
              top: 16,
              left: 16,
              child: _GlassChip(
                text: AppConstants.categoryDisplayName(name.category),
                icon: Icons.category_rounded,
                fontSize: 11,
              ),
            ),

            // Gender indicator — top right
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: genderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: genderColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _genderSymbol,
                      style: TextStyle(fontSize: 12, color: genderColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _genderLabel,
                      style: TextStyle(
                        color: genderColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content - centered name
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // THE NAME - hero element
                    Text(
                      name.name,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTypography.fontFamily,
                        height: 1.0,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                          Shadow(
                            color: Color(0x33000000),
                            blurRadius: 40,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),

                    const SizedBox(height: 10),

                    // Decorative divider line
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Meaning
                    if (hasMeaning)
                      Text(
                        '"${name.meaning}"',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppTypography.fontFamily,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                      ),

                    const Spacer(flex: 2),

                    // Bottom info row
                    if (hasOrigin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.public_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Origin: ${name.origin}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTypography.fontFamily,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double fontSize;

  const _GlassChip({required this.text, this.icon, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamily,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
