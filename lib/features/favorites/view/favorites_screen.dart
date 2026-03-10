import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/core/routing/route_names.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:namora/models/favorite_model.dart';
import 'package:namora/features/swipe/viewmodel/swipe_viewmodel.dart';
import 'package:namora/services/ads/ad_service.dart';
import 'package:namora/services/pdf/pdf_export_service.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesViewModelProvider.notifier).loadFavorites();
    });
  }

  Future<void> _onRefresh() async {
    ref.read(favoritesViewModelProvider.notifier).loadFavorites();
  }

  void _removeFav(FavoriteModel fav) {
    ref.read(favoritesViewModelProvider.notifier).removeFavorite(fav);
  }

  @override
  Widget build(BuildContext context) {
    final favState = ref.watch(favoritesViewModelProvider);
    final genderFilter = ref.watch(favGenderFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final stats = ref.watch(swipeStatsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showSortMenu(context),
                      icon: const Icon(Icons.sort_rounded),
                    ),
                    IconButton(
                      onPressed: favState.favorites.isEmpty
                          ? null
                          : () => _exportPdf(context),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats + Compare quick action cards
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.analytics_rounded,
                    label: 'Your Stats',
                    value: '${stats.totalSwiped} swiped',
                    gradient: [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.7),
                    ],
                    onTap: () => context.push(RouteNames.statistics),
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.compare_arrows_rounded,
                    label: 'Compare',
                    value: 'Side by side',
                    gradient: const [
                      Color(0xFF7C4DFF),
                      Color(0xFFAA00FF),
                    ],
                    onTap: () => context.push(RouteNames.comparison),
                  ),
                ),
              ],
            ),
          ),

          // Gender filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                _GenderFilterChip(
                  label: 'All',
                  icon: Icons.all_inclusive_rounded,
                  value: null,
                  selected: genderFilter,
                  color: primaryColor,
                  isDark: isDark,
                ),
                AppSpacing.gapW8,
                _GenderFilterChip(
                  label: 'Boys',
                  icon: Icons.male_rounded,
                  value: 'male',
                  selected: genderFilter,
                  color: AppColors.genderMale,
                  isDark: isDark,
                ),
                AppSpacing.gapW8,
                _GenderFilterChip(
                  label: 'Girls',
                  icon: Icons.female_rounded,
                  value: 'female',
                  selected: genderFilter,
                  color: AppColors.genderFemale,
                  isDark: isDark,
                ),
                AppSpacing.gapW8,
                _GenderFilterChip(
                  label: 'Unisex',
                  icon: Icons.transgender_rounded,
                  value: 'unisex',
                  selected: genderFilter,
                  color: AppColors.genderUnisex,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Favorites count
          if (favState.favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
              child: Text(
                '${favState.favorites.length} name${favState.favorites.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),

          // List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBody(favState, isDark),
            ),
          ),
          // Navbar spacing
          AppSpacing.navBarSpacer,
        ],
      ),
    );
  }

  Widget _buildBody(FavoritesState favState, bool isDark) {
    if (favState.isLoading && favState.favorites.isEmpty) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }

    if (favState.favorites.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      key: const ValueKey('list'),
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: favState.favorites.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
        ),
        itemBuilder: (context, index) {
          final fav = favState.favorites[index];
          final gradColors = CardGradients.colorsForCategory(fav.category);

          return Dismissible(
            key: ValueKey('${fav.name}_${fav.category}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              HapticFeedback.mediumImpact();
              return true;
            },
            onDismissed: (_) {
              _removeFav(fav);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              onTap: () => context.push(RouteNames.nameDetail, extra: fav),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradColors,
                  ),
                ),
                child: Center(
                  child: Text(
                    fav.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              title: Text(
                fav.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: fav.meaning.isNotEmpty
                  ? Text(
                      fav.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: gradColors[0].withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppConstants.categoryDisplayName(fav.category),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: gradColors[0],
                      ),
                    ),
                  ),
                  AppSpacing.gapW4,
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _removeFav(fav);
                    },
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 22,
                      color: AppColors.favorite,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: isDark
                  ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            AppSpacing.gapH16,
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH8,
            Text(
              'Swipe right on names you love!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Newest First'),
              onTap: () {
                ref.read(favSortProvider.notifier).state = FavSortOrder.newest;
                ref.read(favoritesViewModelProvider.notifier).loadFavorites();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Oldest First'),
              onTap: () {
                ref.read(favSortProvider.notifier).state = FavSortOrder.oldest;
                ref.read(favoritesViewModelProvider.notifier).loadFavorites();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('A - Z'),
              onTap: () {
                ref.read(favSortProvider.notifier).state = FavSortOrder.az;
                ref.read(favoritesViewModelProvider.notifier).loadFavorites();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Z - A'),
              onTap: () {
                ref.read(favSortProvider.notifier).state = FavSortOrder.za;
                ref.read(favoritesViewModelProvider.notifier).loadFavorites();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    // Show rewarded ad before allowing PDF export
    final rewarded = await AdService.instance.showRewardedAd();
    if (!rewarded) return;

    if (!context.mounted) return;
    final favState = ref.read(favoritesViewModelProvider);
    await PdfExportService.exportFavorites(favState.favorites);
  }
}

// Quick action card for Stats / Compare
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced gender filter chip
class _GenderFilterChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final String? value;
  final String? selected;
  final Color color;
  final bool isDark;

  const _GenderFilterChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(favGenderFilterProvider.notifier).state =
              isSelected ? null : value;
          ref.read(favoritesViewModelProvider.notifier).loadFavorites();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? color
                    : (isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
