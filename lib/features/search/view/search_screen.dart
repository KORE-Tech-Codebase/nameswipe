import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/constants/spacing.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/core/theme/card_gradients.dart';
import 'package:nameswipe/features/search/viewmodel/search_viewmodel.dart';
import 'package:nameswipe/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:nameswipe/models/favorite_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Restore query if returning to screen
      final existingQuery = ref.read(searchQueryProvider);
      if (existingQuery.isNotEmpty) {
        _searchController.text = existingQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final query = ref.read(searchQueryProvider);
    if (query.isNotEmpty) {
      ref.read(searchViewModelProvider.notifier).onQueryChanged(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final filter = ref.watch(searchFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) {
                ref.read(searchViewModelProvider.notifier).onQueryChanged(q);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search names...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchViewModelProvider.notifier)
                              .onQueryChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Gender filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGenderChip('All', null, filter.gender, isDark),
                  AppSpacing.gapW8,
                  _buildGenderChip('Male', 'male', filter.gender, isDark),
                  AppSpacing.gapW8,
                  _buildGenderChip('Female', 'female', filter.gender, isDark),
                  AppSpacing.gapW8,
                  _buildGenderChip('Unisex', 'unisex', filter.gender, isDark),
                ],
              ),
            ),
          ),
          // Category chips - scrollable row with distinct colors
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.categories.length,
                separatorBuilder: (_, _) => AppSpacing.gapW8,
                padding: const EdgeInsets.only(right: 20),
                itemBuilder: (context, index) {
                  final cat = AppConstants.categories[index];
                  final selected = filter.categories.contains(cat);
                  final catColors = CardGradients.colorsForCategory(cat);

                  return FilterChip(
                    label: Text(
                      AppConstants.categoryDisplayName(cat),
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : catColors[0],
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    onSelected: (val) {
                      final cats = Set<String>.from(filter.categories);
                      if (val) {
                        cats.add(cat);
                      } else {
                        cats.remove(cat);
                      }
                      ref.read(searchViewModelProvider.notifier).applyFilter(
                            filter.copyWith(categories: cats),
                          );
                    },
                    backgroundColor: catColors[0].withValues(alpha: 0.1),
                    selectedColor: catColors[0],
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? catColors[0]
                          : catColors[0].withValues(alpha: 0.3),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ),
          AppSpacing.gapH8,
          // Results with 3 states
          Expanded(
            child: _buildBody(searchState, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState searchState, bool isDark) {
    // Loading state
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Initial empty state (no search performed)
    if (!searchState.hasSearched) {
      return _buildInitialState(isDark);
    }

    // No results state
    if (searchState.results.isEmpty) {
      return _buildNoResultsState(isDark);
    }

    // Content state
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: searchState.results.length + 1,
        separatorBuilder: (_, index) {
          if (index == searchState.results.length - 1) {
            return const SizedBox.shrink();
          }
          return Divider(
            height: 1,
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariant,
          );
        },
        itemBuilder: (context, index) {
          // Bottom padding item
          if (index == searchState.results.length) {
            return const SizedBox(height: 80);
          }

          final name = searchState.results[index];
          final gradColors = CardGradients.colorsForCategory(name.category);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
                  name.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              name.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: name.meaning.isNotEmpty
                ? Text(
                    name.meaning,
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
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border_rounded),
              color: AppColors.favorite,
              onPressed: () async {
                final repo = ref.read(favoritesRepositoryProvider);
                await repo.addFavorite(FavoriteModel(
                  name: name.name,
                  gender: name.gender,
                  origin: name.origin,
                  meaning: name.meaning,
                  category: name.category,
                  favoritedAt: DateTime.now(),
                ));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${name.name} added to favorites'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: isDark
                  ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            AppSpacing.gapH16,
            Text(
              'Search thousands of names',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH8,
            Text(
              'Type a name, letter, or meaning to get started',
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

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark
                  ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            AppSpacing.gapH16,
            Text(
              'No names found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.gapH8,
            Text(
              'Try a different spelling or remove some filters',
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

  Widget _buildGenderChip(
      String label, String? value, String? currentGender, bool isDark) {
    final isSelected = currentGender == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        final filter = ref.read(searchFilterProvider);
        ref.read(searchViewModelProvider.notifier).applyFilter(
              filter.copyWith(gender: () => isSelected ? null : value),
            );
      },
      visualDensity: VisualDensity.compact,
    );
  }
}
