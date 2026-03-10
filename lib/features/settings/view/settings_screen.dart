import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/routing/route_names.dart';
import 'package:namora/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:namora/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:namora/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:namora/providers/app_providers.dart';
import 'package:namora/widgets/banner_ad_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDarkMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Settings',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),

          // APPEARANCE
          _SectionHeader('APPEARANCE', isDark: isDark),
          // Enhanced dark mode card
          GestureDetector(
            onTap: () =>
                ref.read(settingsViewModelProvider.notifier).toggleTheme(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [const Color(0xFF1A1A2E), const Color(0xFF2D2D44)]
                            : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDarkMode
                          ? const Color(0xFFFFD54F)
                          : const Color(0xFFFF9800),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDarkMode ? 'On - Easy on the eyes' : 'Off - Bright & vibrant',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Custom toggle
                  _ThemeToggle(isDarkMode: isDarkMode),
                ],
              ),
            ),
          ),

          AppSpacing.gapH16,

          // DATA
          _SectionHeader('DATA', isDark: isDark),
          _SettingsTile(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.favorite,
            title: 'Favorites',
            subtitle: '${settings.favoritesCount} names saved',
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.warning,
            title: 'Clear Swipe History',
            subtitle: 'Reset and see all names again',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showClearHistoryDialog(context, ref),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.error,
            title: 'Delete All Favorites',
            subtitle: 'Remove all saved names permanently',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showDeleteAllFavsDialog(context, ref),
          ),
          const Divider(height: 1),

          AppSpacing.gapH16,

          // ABOUT
          _SectionHeader('ABOUT', isDark: isDark),
          _SettingsTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB300),
            title: 'Rate Namora',
            subtitle: 'Love the app? Leave a review!',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              } else {
                await inAppReview.openStoreListing(
                  appStoreId: 'com.namora.rkx',
                );
              }
            },
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: primaryColor,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(RouteNames.privacyPolicy),
          ),
          const Divider(height: 1),
          AppSpacing.gapH16,
          const BannerAdWidget(),
          AppSpacing.navBarSpacer,
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Swipe History?'),
        content: const Text(
          'This will reset your swipe session so you can see all names again. Your favorites will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(swipeViewModelProvider.notifier).resetSession();
              ref.read(swipeStatsProvider.notifier).state = const SwipeStats();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Swipe history cleared!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllFavsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Favorites?'),
        content: const Text(
          'This will permanently remove all your saved favorite names. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              ref
                  .read(favoritesViewModelProvider.notifier)
                  .clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// Custom theme toggle widget
class _ThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  const _ThemeToggle({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 52,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1A1A2E), const Color(0xFF3D3D5C)]
              : [const Color(0xFFFFE0B2), const Color(0xFFFF9800)],
        ),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 14,
            color: isDarkMode
                ? const Color(0xFF1A1A2E)
                : const Color(0xFFFF9800),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: isDark
              ? AppColors.onSurfaceVariantDark
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
