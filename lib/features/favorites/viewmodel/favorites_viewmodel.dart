import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/models/favorite_model.dart';
import 'package:nameswipe/features/favorites/repository/favorites_repository.dart';
import 'package:nameswipe/providers/app_providers.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(db: ref.watch(databaseServiceProvider));
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
    loadFavorites();
  }

  final FavoritesRepository _repository;
  final Ref _ref;

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final gender = _ref.read(favGenderFilterProvider);
      final sort = _ref.read(favSortProvider);
      String orderBy;
      switch (sort) {
        case FavSortOrder.newest:
          orderBy = 'favorited_at DESC';
        case FavSortOrder.oldest:
          orderBy = 'favorited_at ASC';
        case FavSortOrder.az:
          orderBy = 'name COLLATE NOCASE ASC';
        case FavSortOrder.za:
          orderBy = 'name COLLATE NOCASE DESC';
      }
      final favs = await _repository.getFavorites(gender: gender, orderBy: orderBy);
      state = state.copyWith(favorites: favs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> removeFavorite(FavoriteModel fav) async {
    await _repository.removeFavorite(fav.name, fav.category);
    final list = List<FavoriteModel>.from(state.favorites)
      ..removeWhere((f) => f.name == fav.name && f.category == fav.category);
    state = state.copyWith(favorites: list);
  }
}
