import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/models/favorite_model.dart';
import 'package:namora/features/favorites/repository/favorites_repository.dart';
import 'package:namora/providers/app_providers.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(favoritesService: ref.watch(favoritesServiceProvider));
});

/// Reactive favorite check. Rebuilds when favoritesRefreshProvider changes.
final isFavoriteProvider = Provider.family<bool, String>((ref, key) {
  ref.watch(favoritesRefreshProvider);
  final repo = ref.watch(favoritesRepositoryProvider);
  final parts = key.split('||');
  if (parts.length != 2) return false;
  return repo.isFavorite(parts[0], parts[1]);
});

enum FavSortOrder { newest, oldest, az, za }

final favSortProvider = StateProvider<FavSortOrder>((ref) => FavSortOrder.newest);
final favGenderFilterProvider = StateProvider<String?>((ref) => null);

final favoritesViewModelProvider =
    StateNotifierProvider<FavoritesViewModel, FavoritesState>((ref) {
  return FavoritesViewModel(ref.watch(favoritesRepositoryProvider), ref);
});

class FavoritesState {
  final List<FavoriteModel> favorites;
  final bool isLoading;

  const FavoritesState({this.favorites = const [], this.isLoading = false});

  FavoritesState copyWith({List<FavoriteModel>? favorites, bool? isLoading}) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoritesViewModel extends StateNotifier<FavoritesState> {
  FavoritesViewModel(this._repository, this._ref) : super(const FavoritesState()) {
    // Auto-reload when refresh trigger fires (e.g. from swipe screen)
    _ref.listen(favoritesRefreshProvider, (prev, next) {
      if (mounted) loadFavorites();
    });
    loadFavorites();
  }

  final FavoritesRepository _repository;
  final Ref _ref;

  void loadFavorites() {
    state = state.copyWith(isLoading: true);
    try {
      final gender = _ref.read(favGenderFilterProvider);
      final sort = _ref.read(favSortProvider);
      String sortBy;
      switch (sort) {
        case FavSortOrder.newest:
          sortBy = 'newest';
        case FavSortOrder.oldest:
          sortBy = 'oldest';
        case FavSortOrder.az:
          sortBy = 'az';
        case FavSortOrder.za:
          sortBy = 'za';
      }
      final favs = _repository.getFavorites(gender: gender, sortBy: sortBy);
      state = state.copyWith(favorites: favs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> removeFavorite(FavoriteModel fav) async {
    await _repository.removeFavorite(fav.name, fav.category);
    // Update local state first, THEN trigger refresh for other providers
    final list = List<FavoriteModel>.from(state.favorites)
      ..removeWhere((f) => f.name == fav.name && f.category == fav.category);
    state = state.copyWith(favorites: list);
    _ref.read(favoritesRefreshProvider.notifier).state++;
  }

  Future<void> addFavorite(FavoriteModel fav) async {
    await _repository.addFavorite(fav);
    // Update local state first, THEN trigger refresh for other providers
    loadFavorites();
    _ref.read(favoritesRefreshProvider.notifier).state++;
  }

  /// Toggle fav state. Returns true if now favorited.
  Future<bool> toggleFavorite(FavoriteModel fav) async {
    final isFav = _repository.isFavorite(fav.name, fav.category);
    if (isFav) {
      await removeFavorite(fav);
      return false;
    } else {
      await addFavorite(fav);
      return true;
    }
  }

  Future<void> clearAllFavorites() async {
    await _repository.clearAll();
    state = state.copyWith(favorites: []);
    _ref.read(favoritesRefreshProvider.notifier).state++;
  }
}
