import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/constants/typography.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/models/favorite_model.dart';
import 'package:namora/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:namora/services/ads/ad_service.dart';

class NameDetailScreen extends ConsumerStatefulWidget {
  final FavoriteModel favorite;

  const NameDetailScreen({super.key, required this.favorite});

  @override
  ConsumerState<NameDetailScreen> createState() => _NameDetailScreenState();
}

class _NameDetailScreenState extends ConsumerState<NameDetailScreen> {
  FavoriteModel get favorite => widget.favorite;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.recordDetailView();
  }

  Future<void> _toggleFav() async {
    if (_isBusy) return;
    _isBusy = true;
    try {
      HapticFeedback.lightImpact();
      await ref.read(favoritesViewModelProvider.notifier).toggleFavorite(favorite);
    } finally {
      _isBusy = false;
    }
  }

  String get _genderSymbol {
    switch (favorite.gender.toLowerCase()) {
      case 'male':
        return '\u2642';
      case 'female':
        return '\u2640';
      default:
        return '\u26A5';
    }
  }

  String get _genderLabel {
    switch (favorite.gender.toLowerCase()) {
      case 'male':
        return 'Boy';
      case 'female':
        return 'Girl';
      default:
        return 'Unisex';
    }
  }

  void _share() {
    final meaning = favorite.meaning.isNotEmpty ? ' - "${favorite.meaning}"' : '';
    final origin = favorite.origin.isNotEmpty ? ' (${favorite.origin})' : '';
    Share.share(
      'Check out this name: ${favorite.name}$meaning$origin\n\nFound on Namora!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final genderColor = AppColors.genderColor(favorite.gender);
    final gradColors = CardGradients.colorsForCategory(favorite.category);
    final favKey = '${favorite.name}||${favorite.category}';
    final isFav = ref.watch(isFavoriteProvider(favKey));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient header with name
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleFav,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey(isFav),
                    color: isFav ? AppColors.favorite : Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: _share,
                icon: const Icon(Icons.share_rounded, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradColors,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          favorite.name,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppTypography.fontFamily,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Color(0x44000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Gender + category pills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _genderSymbol,
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _genderLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppConstants.categoryDisplayName(
                                    favorite.category),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meaning section
                  if (favorite.meaning.isNotEmpty) ...[
                    _SectionLabel('Meaning', isDark: isDark),
                    AppSpacing.gapH8,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '"${favorite.meaning}"',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          fontFamily: AppTypography.fontFamily,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                    AppSpacing.gapH24,
                  ],

                  // Details grid
                  _SectionLabel('Details', isDark: isDark),
                  AppSpacing.gapH12,
                  _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Gender',
                    value: _genderLabel,
                    valueColor: genderColor,
                    isDark: isDark,
                  ),
                  _DetailRow(
                    icon: Icons.category_rounded,
                    label: 'Category',
                    value: AppConstants.categoryDisplayName(favorite.category),
                    valueColor: gradColors[0],
                    isDark: isDark,
                  ),
                  if (favorite.origin.isNotEmpty)
                    _DetailRow(
                      icon: Icons.public_rounded,
                      label: 'Origin',
                      value: favorite.origin,
                      isDark: isDark,
                    ),

                  AppSpacing.gapH24,

                  // Fav / Share buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _toggleFav,
                          icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                          label: Text(isFav ? 'Unfavorite' : 'Add to Favorites'),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFav
                                ? AppColors.favorite.withValues(alpha: 0.15)
                                : AppColors.favorite,
                            foregroundColor: isFav
                                ? AppColors.favorite
                                : Colors.white,
                          ),
                        ),
                      ),
                      AppSpacing.gapW12,
                      OutlinedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                      ),
                    ],
                  ),

                  AppSpacing.gapH32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
