import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/core/routing/route_names.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/features/search/viewmodel/search_viewmodel.dart';
import 'package:namora/models/favorite_model.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/models/filter_model.dart';
import 'package:namora/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:namora/widgets/banner_ad_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SearchFilterSheet(),
    );
  }

  String _buildFilterSummary() {
    final filter = ref.read(searchFilterProvider);
    final parts = <String>[];

    if (filter.gender != null) {
      final label = switch (filter.gender) {
        'male' => 'Boys',
        'female' => 'Girls',
        'unisex' => 'Unisex',
        _ => filter.gender!,
      };
      parts.add(label);
    }

    final allSelected =
        filter.categories.length == AppConstants.categories.length;
    if (!allSelected && filter.categories.isNotEmpty) {
      if (filter.categories.length <= 2) {
        parts.addAll(filter.categories
            .map((c) => AppConstants.categoryDisplayName(c)));
      } else {
        parts.add('${filter.categories.length} categories');
      }
    }

    return parts.join(' \u2022 ');
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final filter = ref.watch(searchFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final hasFilters = filter.hasActiveFilters;
    final filterSummary = _buildFilterSummary();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Search',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                // Filter icon
                Stack(
                  children: [
                    IconButton(
                      onPressed: _showFilterSheet,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                    if (hasFilters)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) {
                ref.read(searchViewModelProvider.notifier).onQueryChanged(q);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search names, meanings...',
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

          // Active filters summary + clear button
          if (hasFilters || filterSummary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      filterSummary.isNotEmpty
                          ? filterSummary
                          : 'Filters active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(searchViewModelProvider.notifier)
                          .applyFilter(FilterModel.allCategories());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 12, color: primaryColor),
                          const SizedBox(width: 2),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          AppSpacing.gapH8,

          // Banner ad
          const BannerAdWidget(),

          // Results
          Expanded(
            child: _buildBody(searchState, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState searchState, bool isDark) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Discovery mode (default random names)
    if (searchState.isDiscovery && searchState.results.isNotEmpty) {
      return _buildNamesList(searchState.results, isDark, isDiscovery: true);
    }

    // No results after search
    if (searchState.hasSearched && searchState.results.isEmpty) {
      return _buildNoResultsState(isDark);
    }

    // Search results
    if (searchState.results.isNotEmpty) {
      return _buildNamesList(searchState.results, isDark);
    }

    // Fallback empty
    return _buildInitialState(isDark);
  }

  Widget _buildNamesList(List<NameModel> results, bool isDark,
      {bool isDiscovery = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDiscovery)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Discover names',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        if (!isDiscovery)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              '${results.length} result${results.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length + 1,
            separatorBuilder: (_, index) {
              if (index == results.length - 1) {
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
              if (index == results.length) {
                return AppSpacing.navBarSpacer;
              }

              final name = results[index];
              final gradColors = CardGradients.colorsForCategory(name.category);

              return _SearchResultTile(
                name: name,
                gradColors: gradColors,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
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
}

class _SearchResultTile extends ConsumerStatefulWidget {
  final NameModel name;
  final List<Color> gradColors;
  final bool isDark;

  const _SearchResultTile({
    required this.name,
    required this.gradColors,
    required this.isDark,
  });

  @override
  ConsumerState<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends ConsumerState<_SearchResultTile> {
  bool _isBusy = false;

  Future<void> _toggleFav() async {
    if (_isBusy) return;
    _isBusy = true;
    try {
      HapticFeedback.lightImpact();
      final fav = FavoriteModel(
        name: widget.name.name,
        gender: widget.name.gender,
        origin: widget.name.origin,
        meaning: widget.name.meaning,
        category: widget.name.category,
        favoritedAt: DateTime.now(),
      );
      await ref.read(favoritesViewModelProvider.notifier).toggleFavorite(fav);
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favKey = '${widget.name.name}||${widget.name.category}';
    final isFav = ref.watch(isFavoriteProvider(favKey));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: () {
        final fav = FavoriteModel(
          name: widget.name.name,
          gender: widget.name.gender,
          origin: widget.name.origin,
          meaning: widget.name.meaning,
          category: widget.name.category,
          favoritedAt: DateTime.now(),
        );
        context.push(RouteNames.nameDetail, extra: fav);
      },
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradColors,
          ),
        ),
        child: Center(
          child: Text(
            widget.name.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(
        widget.name.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: widget.name.meaning.isNotEmpty
          ? Text(
              widget.name.meaning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.isDark
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.genderColor(widget.name.gender).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.name.gender == 'male'
                  ? 'Boy'
                  : widget.name.gender == 'female'
                      ? 'Girl'
                      : 'Uni',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.genderColor(widget.name.gender),
              ),
            ),
          ),
          AppSpacing.gapW4,
          GestureDetector(
            onTap: _toggleFav,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(isFav),
                size: 22,
                color: isFav ? AppColors.favorite : (widget.isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Search-specific filter sheet (same UX as homepage filter sheet)
class _SearchFilterSheet extends ConsumerStatefulWidget {
  const _SearchFilterSheet();

  @override
  ConsumerState<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<_SearchFilterSheet> {
  late FilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(searchFilterProvider);
  }

  bool get _allCategoriesSelected =>
      _filter.categories.length == AppConstants.categories.length;

  void _toggleAllCategories() {
    setState(() {
      if (_allCategoriesSelected) {
        _filter = _filter.copyWith(categories: {});
      } else {
        _filter = _filter.copyWith(
            categories: Set<String>.from(AppConstants.categories));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant)
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded,
                                color: primaryColor, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Search Filters',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        if (_filter.hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              setState(() => _filter = _filter.clearAll());
                            },
                            child: Text(
                              'Clear all',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_filter.hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_filter.activeFilterCount} filter${_filter.activeFilterCount > 1 ? 's' : ''} active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    // Gender Section
                    _SectionTitle(
                      title: 'Gender',
                      icon: Icons.wc_rounded,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _GenderOption(
                          label: 'All',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: _filter.gender == null,
                          color: primaryColor,
                          onTap: () => setState(() =>
                              _filter =
                                  _filter.copyWith(gender: () => null)),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Boys',
                          icon: Icons.male_rounded,
                          isSelected: _filter.gender == 'male',
                          color: AppColors.genderMale,
                          onTap: () => setState(() => _filter =
                              _filter.copyWith(
                                  gender: () => _filter.gender == 'male'
                                      ? null
                                      : 'male')),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Girls',
                          icon: Icons.female_rounded,
                          isSelected: _filter.gender == 'female',
                          color: AppColors.genderFemale,
                          onTap: () => setState(() => _filter =
                              _filter.copyWith(
                                  gender: () => _filter.gender == 'female'
                                      ? null
                                      : 'female')),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Unisex',
                          icon: Icons.transgender_rounded,
                          isSelected: _filter.gender == 'unisex',
                          color: AppColors.genderUnisex,
                          onTap: () => setState(() => _filter =
                              _filter.copyWith(
                                  gender: () => _filter.gender == 'unisex'
                                      ? null
                                      : 'unisex')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle(
                          title: 'Categories',
                          icon: Icons.category_rounded,
                          color: primaryColor,
                        ),
                        GestureDetector(
                          onTap: _toggleAllCategories,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _allCategoriesSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _allCategoriesSelected
                                    ? primaryColor.withValues(alpha: 0.4)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _allCategoriesSelected
                                      ? Icons.deselect_rounded
                                      : Icons.select_all_rounded,
                                  size: 14,
                                  color: _allCategoriesSelected
                                      ? primaryColor
                                      : (isDark
                                          ? AppColors.onSurfaceVariantDark
                                          : AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _allCategoriesSelected
                                      ? 'Deselect All'
                                      : 'Select All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _allCategoriesSelected
                                        ? primaryColor
                                        : (isDark
                                            ? AppColors.onSurfaceVariantDark
                                            : AppColors.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_filter.categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${_filter.categories.length} of ${AppConstants.categories.length} selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.categories.map((cat) {
                        final selected = _filter.categories.contains(cat);
                        final catColors =
                            CardGradients.colorsForCategory(cat);
                        final chipColor = catColors[0];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              final cats =
                                  Set<String>.from(_filter.categories);
                              if (selected) {
                                cats.remove(cat);
                              } else {
                                cats.add(cat);
                              }
                              _filter = _filter.copyWith(categories: cats);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? chipColor.withValues(alpha: 0.15)
                                  : (isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? chipColor.withValues(alpha: 0.6)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: chipColor,
                                    ),
                                  ),
                                Text(
                                  AppConstants.categoryDisplayName(cat),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? chipColor
                                        : (isDark
                                            ? AppColors.onSurfaceDark
                                            : AppColors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(searchViewModelProvider.notifier)
                          .applyFilter(_filter);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(14),
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
                size: 22,
                color: isSelected
                    ? color
                    : (isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
