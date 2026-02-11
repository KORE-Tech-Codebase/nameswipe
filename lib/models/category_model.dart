class CategoryModel {
  final String name;
  final int totalNames;
  final int maleCount;
  final int femaleCount;
  final int unisexCount;

  const CategoryModel({
    required this.name,
    this.totalNames = 0,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.unisexCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String? ?? json['category'] as String? ?? '',
      totalNames: json['totalNames'] as int? ?? json['total'] as int? ?? 0,
      maleCount: json['maleCount'] as int? ?? 0,
      femaleCount: json['femaleCount'] as int? ?? 0,
      unisexCount: json['unisexCount'] as int? ?? 0,
    );
  }

  String get displayName {
    switch (name) {
      case 'east_asian':
        return 'East Asian';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}
