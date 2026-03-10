import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/models/filter_model.dart';
import 'package:namora/features/search/repository/search_repository.dart';
import 'package:namora/providers/app_providers.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(api: ref.watch(apiServiceProvider));
});

final searchFilterProvider = StateProvider<FilterModel>((ref) {
  return FilterModel.allCategories();
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
  final bool isDiscovery;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.hasSearched = false,
    this.isDiscovery = false,
  });

  SearchState copyWith({
    List<NameModel>? results,
    bool? isLoading,
    bool? hasSearched,
    bool? isDiscovery,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      isDiscovery: isDiscovery ?? this.isDiscovery,
    );
  }
}

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._repository, this._ref) : super(const SearchState()) {
    loadDiscovery();
  }

  final SearchRepository _repository;
  final Ref _ref;
  Timer? _debounce;

  Future<void> loadDiscovery() async {
    state = state.copyWith(isLoading: true);
    try {
      final filter = _ref.read(searchFilterProvider);
      final results = await _repository.search(
        query: '',
        gender: filter.gender,
        categories:
            filter.categories.isNotEmpty ? filter.categories.toList() : null,
      );
      // Shuffle and take 10 random names
      final shuffled = List<NameModel>.from(results)..shuffle(Random());
      state = SearchState(
        results: shuffled.take(10).toList(),
        isLoading: false,
        hasSearched: false,
        isDiscovery: true,
      );
    } catch (_) {
      state = const SearchState();
    }
  }

  void onQueryChanged(String query) {
    _ref.read(searchQueryProvider.notifier).state = query;
    _debounce?.cancel();
    if (query.isEmpty) {
      loadDiscovery();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = _ref.read(searchQueryProvider);
    if (query.isEmpty) {
      loadDiscovery();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final filter = _ref.read(searchFilterProvider);
      final results = await _repository.search(
        query: query,
        gender: filter.gender,
        categories:
            filter.categories.isNotEmpty ? filter.categories.toList() : null,
      );
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasSearched: true,
        isDiscovery: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasSearched: true,
        isDiscovery: false,
      );
    }
  }

  void applyFilter(FilterModel filter) {
    _ref.read(searchFilterProvider.notifier).state = filter;
    final query = _ref.read(searchQueryProvider);
    if (query.isEmpty) {
      loadDiscovery();
    } else {
      _performSearch();
    }
  }

  void resetSearch() {
    _ref.read(searchQueryProvider.notifier).state = '';
    _ref.read(searchFilterProvider.notifier).state = FilterModel.allCategories();
    state = const SearchState();
    loadDiscovery();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
