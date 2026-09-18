class ProductModel {
  final String key;
  final String name;
  final String price;
  final String condition;
  final String phone;
  final String? sellerName;
  final String? category;
  final String? village;
  final String? imageUrl;
  final bool isPinned;
  final String? notes;
  final int? createdAt;

  ProductModel({
    required this.key,
    required this.name,
    required this.price,
    required this.condition,
    required this.phone,
    this.sellerName,
    this.category,
    this.village,
    this.imageUrl,
    this.isPinned = false,
    this.notes,
    this.createdAt,
  });

  factory ProductModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return ProductModel(
      key: key,
      name: map['productName']?.toString() ?? map['name']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      condition: map['condition']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      sellerName: map['sellerName']?.toString() ?? map['seller']?.toString(),
      category: map['category']?.toString(),
      village: map['village']?.toString(),
      imageUrl: map['imageUrl']?.toString() ?? map['image']?.toString(),
      isPinned: map['isPinned'] == true,
      notes: map['notes']?.toString(),
      createdAt: _toInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': name,
      'price': price,
      'condition': condition,
      'phone': phone,
      'sellerName': sellerName,
      'category': category,
      'village': village,
      'imageUrl': imageUrl,
      'isPinned': isPinned,
      'notes': notes,
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
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
