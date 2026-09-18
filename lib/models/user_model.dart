class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String city;
  final String? office;
  final String? licenseNo;
  final String? role;          // مساح | مقاول | عميل
  final String? specialty;
  final String? photoUrl;
  final int createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.city,
    this.office,
    this.licenseNo,
    this.role,
    this.specialty,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    final raw = map['createdAt'];
    final created = raw is int
        ? raw
        : int.tryParse(raw?.toString() ?? '') ??
            DateTime.now().millisecondsSinceEpoch;
    return UserModel(
      uid: uid,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      city: map['city']?.toString() ??
          map['village']?.toString() ??
          'القاهرة',
      office: map['office']?.toString(),
      licenseNo: map['licenseNo']?.toString(),
      role: map['role']?.toString(),
      specialty: map['specialty']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'office': office,
        'licenseNo': licenseNo,
        'role': role,
        'specialty': specialty,
        'photoUrl': photoUrl,
        'createdAt': createdAt,
      };
}
