import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/models/name_model.dart';
import 'package:nameswipe/models/filter_model.dart';
import 'package:nameswipe/features/search/repository/search_repository.dart';
import 'package:nameswipe/providers/app_providers.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(db: ref.watch(databaseServiceProvider));
});

final searchFilterProvider = StateProvider<FilterModel>((ref) {
  return const FilterModel();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel(ref.watch(searchRepositoryProvider), ref);
});

class SearchState {
  final List<NameModel> results;
  final bool isLoading;
  final bool hasSearched;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.hasSearched = false,
  });

  SearchState copyWith({
    List<NameModel>? results,
    bool? isLoading,
    bool? hasSearched,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._repository, this._ref) : super(const SearchState());

  final SearchRepository _repository;
  final Ref _ref;
  Timer? _debounce;

  void onQueryChanged(String query) {
    _ref.read(searchQueryProvider.notifier).state = query;
    _debounce?.cancel();
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = _ref.read(searchQueryProvider);
    if (query.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final filter = _ref.read(searchFilterProvider);
      final results = await _repository.search(
        query: query,
        gender: filter.gender,
        categories: filter.categories.isNotEmpty ? filter.categories.toList() : null,
        origins: filter.origins.isNotEmpty ? filter.origins.toList() : null,
      );
      state = state.copyWith(results: results, isLoading: false, hasSearched: true);
    } catch (_) {
      state = state.copyWith(isLoading: false, hasSearched: true);
    }
  }

  void applyFilter(FilterModel filter) {
    _ref.read(searchFilterProvider.notifier).state = filter;
    _performSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
