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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Bottom gradient overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category label
                Text(
                  AppConstants.categoryDisplayName(name.category),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Name
                Text(
                  name.name,
                  style: AppTypography.cardName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (name.meaning.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    name.meaning,
                    style: AppTypography.cardMeaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                // Chips
                Row(
                  children: [
                    _Chip(
                      label: name.gender[0].toUpperCase() + name.gender.substring(1),
                      color: AppColors.genderColor(name.gender),
                    ),
                    if (name.origin.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _Chip(label: name.origin, color: Colors.white70),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
    );
  }
}
