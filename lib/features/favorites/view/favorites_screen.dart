import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/theme/card_gradients.dart';
import 'package:nameswipe/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:nameswipe/services/pdf/pdf_export_service.dart';
import 'package:nameswipe/widgets/banner_ad_placeholder.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(favoritesViewModelProvider.notifier).loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final favState = ref.watch(favoritesViewModelProvider);
    final genderFilter = ref.watch(favGenderFilterProvider);

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
                Text('Favorites', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showSortMenu(context),
                      icon: const Icon(Icons.sort_rounded),
                    ),
                    IconButton(
                      onPressed: favState.favorites.isEmpty ? null : () => _exportPdf(context),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Gender filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _GenderChip(label: 'All', value: null, selected: genderFilter),
                const SizedBox(width: 8),
                _GenderChip(label: 'Boys', value: 'male', selected: genderFilter),
                const SizedBox(width: 8),
                _GenderChip(label: 'Girls', value: 'female', selected: genderFilter),
              ],
            ),
          ),
          // List
          Expanded(
            child: favState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : favState.favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No favorites yet', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Swipe right on names you love!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: favState.favorites.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
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
                            onDismissed: (_) {
                              ref.read(favoritesViewModelProvider.notifier).removeFavorite(fav);
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: gradColors[0],
                                child: Text(
                                  fav.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(fav.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: fav.meaning.isNotEmpty
                                  ? Text(fav.meaning, maxLines: 1, overflow: TextOverflow.ellipsis)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.genderColor(fav.gender).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      fav.gender[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.genderColor(fav.gender),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const BannerAdPlaceholder(),
        ],
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
    // TODO: Uncomment when ready to enable ads
    // Show rewarded ad dialog first
    // final adShown = await AdService.showRewardedAd();
    // if (!adShown) return;

    final favState = ref.read(favoritesViewModelProvider);
    await PdfExportService.exportFavorites(favState.favorites);
  }
}

class _GenderChip extends ConsumerWidget {
  final String label;
  final String? value;
  final String? selected;

  const _GenderChip({required this.label, required this.value, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(favGenderFilterProvider.notifier).state = isSelected ? null : value;
        ref.read(favoritesViewModelProvider.notifier).loadFavorites();
      },
    );
  }
}
