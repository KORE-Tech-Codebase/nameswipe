import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/models/name_model.dart';
import 'package:nameswipe/models/filter_model.dart';
import 'package:nameswipe/features/swipe/repository/swipe_repository.dart';
import 'package:nameswipe/providers/app_providers.dart';

final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepository(db: ref.watch(databaseServiceProvider));
});

final swipeFilterProvider = StateProvider<FilterModel>((ref) {
  return const FilterModel();
});

final swipeViewModelProvider =
    StateNotifierProvider<SwipeViewModel, SwipeState>((ref) {
  return SwipeViewModel(ref.watch(swipeRepositoryProvider), ref);
});

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
  SwipeViewModel(this._repository, this._ref) : super(const SwipeState()) {
    loadNames();
  }

  final SwipeRepository _repository;
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

  Future<void> onSwipe(int index, bool isFavorite) async {
    if (index >= state.names.length) return;
    final name = state.names[index];
    await _repository.recordSwipe(name, isFavorite);

    final remaining = List<NameModel>.from(state.names)..removeAt(index);
    state = state.copyWith(names: remaining);

    // Preload more names when running low
    if (remaining.length <= 5) {
      _preloadMore();
    }
  }

  Future<void> _preloadMore() async {
    try {
      final filter = _ref.read(swipeFilterProvider);
      final more = await _repository.getNextBatch(filter: filter);
      final current = List<NameModel>.from(state.names);
      current.addAll(more);
      state = state.copyWith(names: current);
    } catch (_) {}
  }

  void applyFilter(FilterModel filter) {
    _ref.read(swipeFilterProvider.notifier).state = filter;
    loadNames();
  }
}
