import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/models/favorite_model.dart';
import 'package:namora/models/filter_model.dart';
import 'package:namora/features/swipe/repository/swipe_repository.dart';
import 'package:namora/providers/app_providers.dart';
import 'package:namora/services/ads/ad_service.dart';
import 'package:namora/services/cache/favorites_service.dart';

final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepository(api: ref.watch(apiServiceProvider));
});

final swipeFilterProvider = StateProvider<FilterModel>((ref) {
  return FilterModel.allCategories();
});

final swipeViewModelProvider =
    StateNotifierProvider<SwipeViewModel, SwipeState>((ref) {
  return SwipeViewModel(
    ref.watch(swipeRepositoryProvider),
    ref.watch(favoritesServiceProvider),
    ref,
  );
});

// Tracks total swipe stats for the session
final swipeStatsProvider = StateProvider<SwipeStats>((ref) => const SwipeStats());

class SwipeStats {
  final int totalSwiped;
  final int totalFavorited;
  final int totalSkipped;
  final Map<String, int> categoryBreakdown;
  final Map<String, int> genderBreakdown;

  const SwipeStats({
    this.totalSwiped = 0,
    this.totalFavorited = 0,
    this.totalSkipped = 0,
    this.categoryBreakdown = const {},
    this.genderBreakdown = const {},
  });

  SwipeStats recordSwipe(NameModel name, bool isFavorite) {
    final newCatBreakdown = Map<String, int>.from(categoryBreakdown);
    newCatBreakdown[name.category] = (newCatBreakdown[name.category] ?? 0) + 1;

    final newGenderBreakdown = Map<String, int>.from(genderBreakdown);
    newGenderBreakdown[name.gender] = (newGenderBreakdown[name.gender] ?? 0) + 1;

    return SwipeStats(
      totalSwiped: totalSwiped + 1,
      totalFavorited: isFavorite ? totalFavorited + 1 : totalFavorited,
      totalSkipped: isFavorite ? totalSkipped : totalSkipped + 1,
      categoryBreakdown: newCatBreakdown,
      genderBreakdown: newGenderBreakdown,
    );
  }
}

class SwipeState {
  final List<NameModel> names;
  final bool isLoading;
  final String? error;

  const SwipeState({
    this.names = const [],
    this.isLoading = false,
    this.error,
  });

  SwipeState copyWith({
    List<NameModel>? names,
    bool? isLoading,
    String? error,
  }) {
    return SwipeState(
      names: names ?? this.names,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SwipeViewModel extends StateNotifier<SwipeState> {
  SwipeViewModel(this._repository, this._favoritesService, this._ref)
      : super(const SwipeState()) {
    loadNames();
  }

  final SwipeRepository _repository;
  final FavoritesService _favoritesService;
  final Ref _ref;

  Future<void> loadNames() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final filter = _ref.read(swipeFilterProvider);
      final names = await _repository.getNextBatch(filter: filter);
      state = state.copyWith(names: names, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Called by CardSwiper's onSwipe callback.
  /// Does NOT remove from list - lets CardSwiper handle card progression.
  Future<void> onSwipe(int index, bool isFavorite) async {
    if (index >= state.names.length) return;
    final name = state.names[index];

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Mark as seen in session
    _repository.markSeen(name);

    // Record stats
    _ref.read(swipeStatsProvider.notifier).state =
        _ref.read(swipeStatsProvider).recordSwipe(name, isFavorite);

    // Track swipe for interstitial ad
    AdService.instance.recordSwipe();

    // Save to Hive if favorited
    if (isFavorite) {
      HapticFeedback.mediumImpact();
      _favoritesService.addFavorite(FavoriteModel(
        name: name.name,
        gender: name.gender,
        origin: name.origin,
        meaning: name.meaning,
        category: name.category,
        favoritedAt: DateTime.now(),
      ));
      // Trigger favorites refresh
      _ref.read(favoritesRefreshProvider.notifier).state++;
    }
  }

  /// Called when CardSwiper reaches the end of the deck
  void onDeckEnd() {
    loadNames();
  }

  void applyFilter(FilterModel filter) {
    _ref.read(swipeFilterProvider.notifier).state = filter;
    loadNames();
  }

  void resetSession() {
    _repository.clearSeen();
    loadNames();
  }
}
