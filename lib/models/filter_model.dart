class FilterModel {
  final Set<String> categories;
  final String? gender; // null = all, 'male', 'female', 'unisex'
  final Set<String> origins;

  const FilterModel({
    this.categories = const {},
    this.gender,
    this.origins = const {},
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty || gender != null || origins.isNotEmpty;

  int get activeFilterCount =>
      (categories.isNotEmpty ? 1 : 0) +
      (gender != null ? 1 : 0) +
      (origins.isNotEmpty ? 1 : 0);

  FilterModel copyWith({
    Set<String>? categories,
    String? Function()? gender,
    Set<String>? origins,
  }) {
    return FilterModel(
      categories: categories ?? this.categories,
      gender: gender != null ? gender() : this.gender,
      origins: origins ?? this.origins,
    );
  }

  FilterModel clearAll() {
    return const FilterModel();
  }
}
