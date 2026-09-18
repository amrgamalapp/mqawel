class HeroModel {
  final String key;
  final String name;
  final String city;
  final String field;
  final String bio;
  final int? createdAt;
  final String? imageUrl;

  HeroModel({
    required this.key,
    required this.name,
    required this.city,
    required this.field,
    required this.bio,
    this.createdAt,
    this.imageUrl,
  });

  factory HeroModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return HeroModel(
      key: key,
      name: map['name']?.toString() ?? '',
      city: map['city']?.toString() ?? 'القاهرة',
      field: map['field']?.toString() ?? map['title']?.toString() ?? '',
      bio: map['bio']?.toString() ?? map['story']?.toString() ?? '',
      createdAt: HeroModel._toInt(map['createdAt']),
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'field': field,
        'bio': bio,
        'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
        'imageUrl': imageUrl,
      };

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
