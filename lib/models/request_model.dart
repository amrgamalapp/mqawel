class RequestModel {
  final String key;
  final String name;
  final String phone;
  final String category;
  final String details;
  final int? createdAt;

  RequestModel({
    required this.key,
    required this.name,
    required this.phone,
    required this.category,
    required this.details,
    this.createdAt,
  });

  factory RequestModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return RequestModel(
      key: key,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      details: map['details']?.toString() ?? '',
      createdAt: _toInt(map['createdAt']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
