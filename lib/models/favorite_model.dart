class FavoriteModel {
  final int? id;
  final String name;
  final String gender;
  final String origin;
  final String meaning;
  final String category;
  final DateTime favoritedAt;
  final String? notes;

  const FavoriteModel({
    this.id,
    required this.name,
    required this.gender,
    this.origin = '',
    this.meaning = '',
    required this.category,
    required this.favoritedAt,
    this.notes,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      category: json['category'] as String? ?? '',
      favoritedAt: json['favorited_at'] != null
          ? DateTime.parse(json['favorited_at'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'gender': gender,
      'origin': origin,
      'meaning': meaning,
      'category': category,
      'favorited_at': favoritedAt.toIso8601String(),
      'notes': notes,
    };
  }

  FavoriteModel copyWith({
    int? id,
    String? name,
    String? gender,
    String? origin,
    String? meaning,
    String? category,
    DateTime? favoritedAt,
    String? notes,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      origin: origin ?? this.origin,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
      favoritedAt: favoritedAt ?? this.favoritedAt,
      notes: notes ?? this.notes,
    );
  }
}
