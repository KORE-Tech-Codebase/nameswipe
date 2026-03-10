import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/features/settings/repository/settings_repository.dart';
import 'package:namora/providers/app_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    cache: ref.watch(cacheServiceProvider),
    favorites: ref.watch(favoritesServiceProvider),
  );
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  ref.watch(favoritesRefreshProvider);
  return SettingsViewModel(ref.watch(settingsRepositoryProvider), ref);
});

class SettingsState {
  final int favoritesCount;

  const SettingsState({this.favoritesCount = 0});

  SettingsState copyWith({int? favoritesCount}) {
    return SettingsState(
      favoritesCount: favoritesCount ?? this.favoritesCount,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(this._repository, this._ref) : super(const SettingsState()) {
    loadStats();
  }

  final SettingsRepository _repository;
  final Ref _ref;

  void loadStats() {
    state = state.copyWith(favoritesCount: _repository.favoritesCount);
  }

  void toggleTheme() {
    _ref.read(themeProvider.notifier).toggle();
  }
}
