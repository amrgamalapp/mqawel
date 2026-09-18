class ProviderModel {
  final String key;
  final String name;
  final String category;
  final String? subject;
  final String city;
  final String phone;
  final String address;
  final String? notes;
  final String? imageUrl;
  final String? role;          // 'مساح' | 'مقاول' | null
  final String? licenseNo;
  final bool isVerified;
  final bool isPinned;
  final int viewsCount;
  final int? createdAt;
  final int? order;

  ProviderModel({
    required this.key,
    required this.name,
    required this.category,
    this.subject,
    required this.city,
    required this.phone,
    required this.address,
    this.notes,
    this.imageUrl,
    this.role,
    this.licenseNo,
    this.isVerified = false,
    this.isPinned = false,
    this.viewsCount = 0,
    this.createdAt,
    this.order,
  });

  int get sortValue => order ?? createdAt ?? 0;

  factory ProviderModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return ProviderModel(
      key: key,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'مقاولات عامة',
      subject: map['subject']?.toString(),
      city: map['city']?.toString() ??
          map['village']?.toString() ??
          'القاهرة',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      notes: map['notes']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      role: map['role']?.toString(),
      licenseNo: map['licenseNo']?.toString(),
      isVerified: map['isVerified'] == true,
      isPinned: map['isPinned'] == true,
      viewsCount: _toInt(map['viewsCount']) ?? 0,
      createdAt: _toInt(map['createdAt']),
      order: _toInt(map['order']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subject': subject,
      'city': city,
      'address': address,
      'phone': phone,
      'notes': notes,
      'imageUrl': imageUrl,
      'role': role,
      'licenseNo': licenseNo,
      'isVerified': isVerified,
      'isPinned': isPinned,
      'viewsCount': viewsCount,
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'order': order,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
