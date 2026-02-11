import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/core/constants/colors.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/core/theme/card_gradients.dart';
import 'package:nameswipe/features/search/viewmodel/search_viewmodel.dart';
import 'package:nameswipe/features/favorites/viewmodel/favorites_viewmodel.dart';
import 'package:nameswipe/models/favorite_model.dart';
import 'package:nameswipe/widgets/banner_ad_placeholder.dart';

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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final filter = ref.watch(searchFilterProvider);

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => ref.read(searchViewModelProvider.notifier).onQueryChanged(q),
              decoration: InputDecoration(
                hintText: 'Search names...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchViewModelProvider.notifier).onQueryChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGenderChip('All', null, filter.gender),
                  const SizedBox(width: 8),
                  _buildGenderChip('Male', 'male', filter.gender),
                  const SizedBox(width: 8),
                  _buildGenderChip('Female', 'female', filter.gender),
                  const SizedBox(width: 8),
                  _buildGenderChip('Unisex', 'unisex', filter.gender),
                ],
              ),
            ),
          ),
          // Category chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.categories.map((cat) {
                  final selected = filter.categories.contains(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(AppConstants.categoryDisplayName(cat), style: const TextStyle(fontSize: 12)),
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
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !searchState.hasSearched
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('Search for baby names', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : searchState.results.isEmpty
                        ? Center(child: Text('No results found', style: Theme.of(context).textTheme.bodyLarge))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: searchState.results.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final name = searchState.results[index];
                              final gradColors = CardGradients.colorsForCategory(name.category);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: gradColors[0],
                                  radius: 20,
                                  child: Text(
                                    name.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                title: Text(name.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: name.meaning.isNotEmpty
                                    ? Text(name.meaning, maxLines: 1, overflow: TextOverflow.ellipsis)
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite_border),
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
                                        SnackBar(content: Text('${name.name} added to favorites')),
                                      );
                                    }
                                  },
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

  Widget _buildGenderChip(String label, String? value, String? currentGender) {
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
