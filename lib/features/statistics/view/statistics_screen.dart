import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:namora/providers/app_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(swipeStatsProvider);
    final favCount = ref.watch(favoritesServiceProvider).count;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final favRate = stats.totalSwiped > 0
        ? (stats.totalFavorited / stats.totalSwiped * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Statistics'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Top stats cards
          Row(
            children: [
              _StatCard(
                label: 'Swiped',
                value: '${stats.totalSwiped}',
                icon: Icons.swipe_rounded,
                color: primaryColor,
                isDark: isDark,
              ),
              AppSpacing.gapW12,
              _StatCard(
                label: 'Loved',
                value: '${stats.totalFavorited}',
                icon: Icons.favorite_rounded,
                color: AppColors.favorite,
                isDark: isDark,
              ),
              AppSpacing.gapW12,
              _StatCard(
                label: 'Skipped',
                value: '${stats.totalSkipped}',
                icon: Icons.close_rounded,
                color: AppColors.skip,
                isDark: isDark,
              ),
            ],
          ),
          AppSpacing.gapH20,

          // Favorite rate + total saved
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  AppColors.favorite.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$favRate%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Favorite Rate',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$favCount',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.favorite,
                        ),
                      ),
                      Text(
                        'Total Saved',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH24,

          // Gender breakdown
          if (stats.genderBreakdown.isNotEmpty) ...[
            Text(
              'Gender Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH12,
            Row(
              children: [
                if (stats.genderBreakdown.containsKey('male'))
                  _GenderStat(
                    label: 'Boys',
                    count: stats.genderBreakdown['male']!,
                    color: AppColors.genderMale,
                    isDark: isDark,
                  ),
                if (stats.genderBreakdown.containsKey('female'))
                  _GenderStat(
                    label: 'Girls',
                    count: stats.genderBreakdown['female']!,
                    color: AppColors.genderFemale,
                    isDark: isDark,
                  ),
                if (stats.genderBreakdown.containsKey('unisex'))
                  _GenderStat(
                    label: 'Unisex',
                    count: stats.genderBreakdown['unisex']!,
                    color: AppColors.genderUnisex,
                    isDark: isDark,
                  ),
              ],
            ),
            AppSpacing.gapH24,
          ],

          // Category breakdown
          if (stats.categoryBreakdown.isNotEmpty) ...[
            Text(
              'Categories Explored',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH12,
            ...(stats.categoryBreakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .map((entry) {
              final maxCount = stats.categoryBreakdown.values
                  .fold(0, (a, b) => a > b ? a : b);
              final progress = maxCount > 0 ? entry.value / maxCount : 0.0;
              final catColors = CardGradients.colorsForCategory(entry.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppConstants.categoryDisplayName(entry.key),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: catColors[0],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: (isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant),
                        color: catColors[0],
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Empty state
          if (stats.totalSwiped == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: (isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant)
                          .withValues(alpha: 0.4),
                    ),
                    AppSpacing.gapH16,
                    Text(
                      'No stats yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      'Start swiping to see your insights!',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          AppSpacing.navBarSpacer,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _GenderStat({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
