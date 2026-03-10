import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/core/constants/colors.dart';
import 'package:namora/core/constants/spacing.dart';
import 'package:namora/core/theme/card_gradients.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/providers/app_providers.dart';
import 'package:namora/models/favorite_model.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  FavoriteModel? _left;
  FavoriteModel? _right;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final favorites = ref.watch(favoritesServiceProvider).getAllFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Names'),
        centerTitle: true,
      ),
      body: favorites.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 64,
                      color: (isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant)
                          .withValues(alpha: 0.4),
                    ),
                    AppSpacing.gapH16,
                    Text(
                      'Need at least 2 favorites',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      'Save more names to your favorites to compare them!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Selection row
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _NameSelector(
                          label: 'Name A',
                          selected: _left,
                          favorites: favorites,
                          exclude: _right,
                          onSelected: (fav) => setState(() => _left = fav),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.compare_arrows_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      Expanded(
                        child: _NameSelector(
                          label: 'Name B',
                          selected: _right,
                          favorites: favorites,
                          exclude: _left,
                          onSelected: (fav) => setState(() => _right = fav),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Comparison cards
                if (_left != null && _right != null)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Side by side name cards
                        Row(
                          children: [
                            Expanded(
                                child: _CompareCard(
                                    fav: _left!, isDark: isDark)),
                            AppSpacing.gapW12,
                            Expanded(
                                child: _CompareCard(
                                    fav: _right!, isDark: isDark)),
                          ],
                        ),
                        AppSpacing.gapH24,

                        // Attribute comparison rows
                        _CompareRow(
                          label: 'Gender',
                          left: _left!.gender,
                          right: _right!.gender,
                          leftColor: AppColors.genderColor(_left!.gender),
                          rightColor: AppColors.genderColor(_right!.gender),
                          isDark: isDark,
                        ),
                        _CompareRow(
                          label: 'Category',
                          left: AppConstants.categoryDisplayName(_left!.category),
                          right: AppConstants.categoryDisplayName(_right!.category),
                          leftColor: CardGradients.colorsForCategory(_left!.category)[0],
                          rightColor: CardGradients.colorsForCategory(_right!.category)[0],
                          isDark: isDark,
                        ),
                        if (_left!.origin.isNotEmpty || _right!.origin.isNotEmpty)
                          _CompareRow(
                            label: 'Origin',
                            left: _left!.origin.isNotEmpty ? _left!.origin : '—',
                            right: _right!.origin.isNotEmpty ? _right!.origin : '—',
                            isDark: isDark,
                          ),
                        if (_left!.meaning.isNotEmpty || _right!.meaning.isNotEmpty) ...[
                          AppSpacing.gapH16,
                          Text(
                            'Meanings',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          AppSpacing.gapH8,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _left!.meaning.isNotEmpty
                                        ? '"${_left!.meaning}"'
                                        : 'No meaning available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: _left!.meaning.isNotEmpty
                                          ? null
                                          : (isDark
                                              ? AppColors.onSurfaceVariantDark
                                              : AppColors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacing.gapW12,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _right!.meaning.isNotEmpty
                                        ? '"${_right!.meaning}"'
                                        : 'No meaning available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: _right!.meaning.isNotEmpty
                                          ? null
                                          : (isDark
                                              ? AppColors.onSurfaceVariantDark
                                              : AppColors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        AppSpacing.navBarSpacer,
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _NameSelector extends StatelessWidget {
  final String label;
  final FavoriteModel? selected;
  final List<FavoriteModel> favorites;
  final FavoriteModel? exclude;
  final ValueChanged<FavoriteModel> onSelected;
  final bool isDark;
  final Color primaryColor;

  const _NameSelector({
    required this.label,
    required this.selected,
    required this.favorites,
    required this.exclude,
    required this.onSelected,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choose $label',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...favorites
                  .where((f) =>
                      exclude == null ||
                      f.name != exclude!.name ||
                      f.category != exclude!.category)
                  .map((fav) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              CardGradients.colorsForCategory(fav.category)[0],
                          child: Text(
                            fav.name[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(fav.name),
                        subtitle: Text(
                            '${fav.gender} · ${AppConstants.categoryDisplayName(fav.category)}'),
                        onTap: () {
                          onSelected(fav);
                          Navigator.pop(context);
                        },
                      )),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected != null
                ? primaryColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected != null ? Icons.person_rounded : Icons.add_circle_outline,
              color: selected != null ? primaryColor : AppColors.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              selected?.name ?? label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected != null ? null : AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (selected == null)
              Text(
                'Tap to choose',
                style: TextStyle(
                  fontSize: 11,
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

class _CompareCard extends StatelessWidget {
  final FavoriteModel fav;
  final bool isDark;

  const _CompareCard({required this.fav, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gradColors = CardGradients.colorsForCategory(fav.category);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradColors,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            fav.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (fav.meaning.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              fav.meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String left;
  final String right;
  final Color? leftColor;
  final Color? rightColor;
  final bool isDark;

  const _CompareRow({
    required this.label,
    required this.left,
    required this.right,
    this.leftColor,
    this.rightColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: leftColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: rightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
