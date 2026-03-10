import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/models/filter_model.dart';
import 'package:namora/features/swipe/viewmodel/swipe_viewmodel.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late FilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(swipeFilterProvider);
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + Header (fixed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    // Handle
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
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, color: primaryColor, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Filters',
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
                    // Active filter count
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
                          onTap: () => setState(
                              () => _filter = _filter.copyWith(gender: () => null)),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Boys',
                          icon: Icons.male_rounded,
                          isSelected: _filter.gender == 'male',
                          color: AppColors.genderMale,
                          onTap: () => setState(() => _filter = _filter.copyWith(
                              gender: () =>
                                  _filter.gender == 'male' ? null : 'male')),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Girls',
                          icon: Icons.female_rounded,
                          isSelected: _filter.gender == 'female',
                          color: AppColors.genderFemale,
                          onTap: () => setState(() => _filter = _filter.copyWith(
                              gender: () =>
                                  _filter.gender == 'female' ? null : 'female')),
                        ),
                        AppSpacing.gapW8,
                        _GenderOption(
                          label: 'Unisex',
                          icon: Icons.transgender_rounded,
                          isSelected: _filter.gender == 'unisex',
                          color: AppColors.genderUnisex,
                          onTap: () => setState(() => _filter = _filter.copyWith(
                              gender: () =>
                                  _filter.gender == 'unisex' ? null : 'unisex')),
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
                        // All toggle
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
                        final catColors = CardGradients.colorsForCategory(cat);
                        final chipColor = catColors[0];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              final cats = Set<String>.from(_filter.categories);
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
                                    padding: const EdgeInsets.only(right: 6),
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
                                    fontWeight:
                                        selected ? FontWeight.w700 : FontWeight.w500,
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
              // Bottom Apply button
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
                          .read(swipeViewModelProvider.notifier)
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
