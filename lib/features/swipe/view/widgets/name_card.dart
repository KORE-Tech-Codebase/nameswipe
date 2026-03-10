import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/constants/typography.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/models/name_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final genderColor = AppColors.genderColor(name.gender);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative geometric pattern layer
            Positioned.fill(
              child: CustomPaint(
                painter: _GeometricPatternPainter(
                  seed: name.name.hashCode,
                  accentColor: genderColor,
                ),
              ),
            ),

            // Dotted grid overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  seed: name.name.hashCode ^ name.category.hashCode,
                ),
              ),
            ),

            // Bottom gradient overlay for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Top subtle gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Category chip — top right
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  AppConstants.categoryDisplayName(name.category),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Center content: name + gender symbol + meaning
            Positioned(
              left: 28,
              right: 28,
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name row with gender symbol
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          name.name,
                          style: AppTypography.cardName.copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _genderSymbol,
                        style: TextStyle(
                          fontSize: 28,
                          color: genderColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(
                              color: genderColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Meaning
                  if (name.meaning.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      name.meaning,
                      style: AppTypography.cardMeaning.copyWith(
                        height: 1.4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Bottom chips: gender + origin
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Row(
                children: [
                  _Chip(
                    label: name.gender[0].toUpperCase() +
                        name.gender.substring(1),
                    color: genderColor,
                    icon: _genderSymbol,
                  ),
                  if (name.origin.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    _Chip(
                      label: name.origin,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ],
              ),
            ),

            // Decorative top-left accent line
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: genderColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final String? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(
              icon!,
              style: TextStyle(
                fontSize: 11,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
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

// Draws randomized geometric shapes (circles, diamonds, stars, dots)
// seeded by the name's hash so each name gets a unique but consistent pattern.
class _GeometricPatternPainter extends CustomPainter {
  final int seed;
  final Color accentColor;

  _GeometricPatternPainter({required this.seed, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final shapeCount = 8 + rng.nextInt(6); // 8-13 shapes

    for (int i = 0; i < shapeCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = 12.0 + rng.nextDouble() * 50.0;
      final opacity = 0.03 + rng.nextDouble() * 0.07;
      final shapeType = rng.nextInt(4);

      final paint = Paint()
        ..color = (i % 3 == 0 ? accentColor : Colors.white)
            .withValues(alpha: opacity)
        ..style = rng.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.0 + rng.nextDouble() * 1.5;

      switch (shapeType) {
        case 0:
          // Circle
          canvas.drawCircle(Offset(x, y), radius, paint);
          break;
        case 1:
          // Diamond
          _drawDiamond(canvas, Offset(x, y), radius, paint);
          break;
        case 2:
          // Star
          _drawStar(canvas, Offset(x, y), radius * 0.8, 4 + rng.nextInt(3), paint);
          break;
        case 3:
          // Ring (double circle)
          canvas.drawCircle(
            Offset(x, y),
            radius,
            paint..style = PaintingStyle.stroke,
          );
          if (rng.nextBool()) {
            canvas.drawCircle(
              Offset(x, y),
              radius * 0.6,
              Paint()
                ..color = paint.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = paint.strokeWidth * 0.7,
            );
          }
          break;
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.6, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawStar(
      Canvas canvas, Offset center, double radius, int points, Paint paint) {
    final path = Path();
    final innerRadius = radius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GeometricPatternPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.accentColor != accentColor;
}

// Draws a subtle dotted grid / abstract pattern overlay.
class _DotGridPainter extends CustomPainter {
  final int seed;

  _DotGridPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final spacing = 28.0 + (rng.nextInt(12)).toDouble();
    final dotRadius = 0.6 + rng.nextDouble() * 0.5;
    final offsetX = rng.nextDouble() * spacing;
    final offsetY = rng.nextDouble() * spacing;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (double x = offsetX; x < size.width; x += spacing) {
      for (double y = offsetY; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }

    // Draw a few subtle connecting lines between random dots
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final lineCount = 3 + rng.nextInt(4);
    for (int i = 0; i < lineCount; i++) {
      final x1 = rng.nextDouble() * size.width;
      final y1 = rng.nextDouble() * size.height;
      final x2 = x1 + (rng.nextDouble() - 0.5) * 150;
      final y2 = y1 + (rng.nextDouble() - 0.5) * 150;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
