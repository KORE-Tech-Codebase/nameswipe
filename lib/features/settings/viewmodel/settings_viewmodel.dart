import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/features/settings/repository/settings_repository.dart';
import 'package:nameswipe/providers/app_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    cache: ref.watch(cacheServiceProvider),
    db: ref.watch(databaseServiceProvider),
  );
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(ref.watch(settingsRepositoryProvider), ref);
});

class SettingsState {
  final int totalNames;
  final int swipeCount;
  final int favoritesCount;
  final bool isLoading;

  const SettingsState({
    this.totalNames = 0,
    this.swipeCount = 0,
    this.favoritesCount = 0,
    this.isLoading = false,
  });

  SettingsState copyWith({int? totalNames, int? swipeCount, int? favoritesCount, bool? isLoading}) {
    return SettingsState(
      totalNames: totalNames ?? this.totalNames,
      swipeCount: swipeCount ?? this.swipeCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(this._repository, this._ref) : super(const SettingsState()) {
    loadStats();
  }

  final SettingsRepository _repository;
  final Ref _ref;

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final total = await _repository.getTotalNames();
      final swipes = await _repository.getSwipeCount();
      final favs = await _repository.getFavoritesCount();
      state = state.copyWith(
        totalNames: total,
        swipeCount: swipes,
        favoritesCount: favs,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearSwipeHistory() async {
    await _repository.clearSwipeHistory();
    await loadStats();
  }

  void toggleTheme() {
    _ref.read(themeProvider.notifier).toggle();
  }
}
