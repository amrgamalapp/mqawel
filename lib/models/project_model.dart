class ProjectModel {
  final String key;
  final String name;
  final String city;
  final String type;        // example: 'مبنى سكني', 'فيلا', 'مجمع تجاري'
  final String scope;        // example: 'تشطيب كامل', 'هيكل خرساني'
  final String description;
  final String? imageUrl;
  final int? createdAt;

  ProjectModel({
    required this.key,
    required this.name,
    required this.city,
    required this.type,
    required this.scope,
    required this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory ProjectModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return ProjectModel(
      key: key,
      name: map['name']?.toString() ?? '',
      city: map['city']?.toString() ??
          map['village']?.toString() ??
          'القاهرة',
      type: map['type']?.toString() ?? 'مشروع',
      scope: map['scope']?.toString() ?? '',
      description: map['description']?.toString() ??
          map['bio']?.toString() ??
          '',
      imageUrl: map['imageUrl']?.toString(),
      createdAt: _toInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'type': type,
        'scope': scope,
        'description': description,
        'imageUrl': imageUrl,
        'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      };

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
