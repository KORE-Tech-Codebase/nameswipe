class NameModel {
  final int? id;
  final String name;
  final String gender;
  final String origin;
  final String meaning;
  final String category;

  const NameModel({
    this.id,
    required this.name,
    required this.gender,
    this.origin = '',
    this.meaning = '',
    required this.category,
  });

  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      category: json['category'] as String? ?? '',
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
    };
  }

  NameModel copyWith({
    int? id,
    String? name,
    String? gender,
    String? origin,
    String? meaning,
    String? category,
  }) {
    return NameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      origin: origin ?? this.origin,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          category == other.category;

  @override
  int get hashCode => name.hashCode ^ category.hashCode;

  @override
  String toString() => 'NameModel(name: $name, gender: $gender, category: $category)';
}
