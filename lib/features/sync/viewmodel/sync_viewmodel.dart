import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/features/sync/repository/sync_repository.dart';
import 'package:nameswipe/providers/app_providers.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    db: ref.watch(databaseServiceProvider),
    api: ref.watch(apiServiceProvider),
  );
});

final syncViewModelProvider =
    StateNotifierProvider<SyncViewModel, SyncState>((ref) {
  return SyncViewModel(ref.watch(syncRepositoryProvider));
});

class SyncState {
  final bool isSyncing;
  final int completedCategories;
  final int totalCategories;
  final String? currentCategory;

  const SyncState({
    this.isSyncing = false,
    this.completedCategories = 0,
    this.totalCategories = 19,
    this.currentCategory,
  });

  bool get isComplete => completedCategories >= totalCategories;

  SyncState copyWith({
    bool? isSyncing,
    int? completedCategories,
    int? totalCategories,
    String? currentCategory,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      completedCategories: completedCategories ?? this.completedCategories,
      totalCategories: totalCategories ?? this.totalCategories,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

class SyncViewModel extends StateNotifier<SyncState> {
  SyncViewModel(this._repository) : super(const SyncState()) {
    _checkStatus();
  }

  final SyncRepository _repository;

  Future<void> _checkStatus() async {
    final statuses = await _repository.getSyncStatuses();
    final completed = statuses.where((s) => s.isCompleted).length;
    state = state.copyWith(completedCategories: completed);
  }

  Future<void> startSync() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);

    final statuses = await _repository.getSyncStatuses();
    final completedCats = statuses.where((s) => s.isCompleted).map((s) => s.category).toSet();

    int completed = completedCats.length;

    for (final category in AppConstants.categories) {
      if (completedCats.contains(category)) continue;

      state = state.copyWith(currentCategory: category);
      await _repository.syncCategory(category, onProgress: (status) {
        if (status.isCompleted) {
          completed++;
          state = state.copyWith(completedCategories: completed);
        }
      });
    }

    state = state.copyWith(isSyncing: false, currentCategory: null);
  }
}
