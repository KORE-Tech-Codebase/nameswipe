class SyncStatusModel {
  final String category;
  final int lastPage;
  final int totalPages;
  final int totalNames;
  final int syncedNames;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const SyncStatusModel({
    required this.category,
    this.lastPage = 0,
    this.totalPages = 0,
    this.totalNames = 0,
    this.syncedNames = 0,
    this.completedAt,
    required this.updatedAt,
  });

  bool get isCompleted => completedAt != null;

  double get progress =>
      totalNames > 0 ? (syncedNames / totalNames).clamp(0.0, 1.0) : 0.0;

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      category: json['category'] as String,
      lastPage: json['last_page'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      totalNames: json['total_names'] as int? ?? 0,
      syncedNames: json['synced_names'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'last_page': lastPage,
      'total_pages': totalPages,
      'total_names': totalNames,
      'synced_names': syncedNames,
      'completed_at': completedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
