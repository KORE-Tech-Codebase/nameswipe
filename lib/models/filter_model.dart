import 'package:namora/core/constants/app_constants.dart';

class FilterModel {
  final Set<String> categories;
  final String? gender; // null = all, 'male', 'female', 'unisex'
  final Set<String> origins;

  const FilterModel({
    this.categories = const {},
    this.gender,
    this.origins = const {},
  });

  /// Default filter with all categories selected
  factory FilterModel.allCategories() {
    return FilterModel(
      categories: Set<String>.from(AppConstants.categories),
    );
  }

  bool get hasActiveFilters =>
      gender != null ||
      origins.isNotEmpty ||
      (categories.isNotEmpty &&
          categories.length != AppConstants.categories.length);

  int get activeFilterCount =>
      ((categories.isNotEmpty &&
                  categories.length != AppConstants.categories.length)
              ? 1
              : 0) +
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
    return FilterModel.allCategories();
  }
}
